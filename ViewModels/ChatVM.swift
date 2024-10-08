//
//  ChatVM.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 06/06/2023.
//

import Foundation
import SwiftUI
import Combine
import Alamofire
import FirebaseFirestore
import OpenAIKit
import FirebaseStorage

class ChatVM: ObservableObject {
    
    //MARK: View Binding
    @Published var msgsArr: [Message] = []
    @Published var currentInput: String = ""
    @Published var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @Published var dreamInterpretedText: String = ""
    @Published var dreamInterpretedImage: UIImage?
    @Published var errorMessage: String = ""
    @Published var tags: [String] = []
    
    // MARK: Toggles
    @Published var isLoading: Bool = false
    @Published var isPaywallPresented = false
    @Published var isDreamSaved = false
    
    // MARK: Service
    private let db = Firestore.firestore()
    private let openAIService = OpenAIService()
    private var openAI: OpenAI?
    
    // MARK: Initialization
    init(with text: String, messages: [Message] = [], selectedDate: Date = .now) {
        currentInput = text
        self.msgsArr = messages
        self.selectedDate = selectedDate
    }
    
    func setup() {
        openAI = OpenAI(Configuration(organizationId: "Personal", apiKey: EnvironmentInfo.apiKey))
    }
    
    func generateImage(prompt: String) async -> UIImage? {
        guard let openai = openAI else { return nil }
        do {
            isLoading.toggle()
            let params = ImageParameters(prompt: prompt, resolution: .medium, responseFormat: .base64Json)
            let result = try await openai.createImage(parameters: params)
            let data = result.data[0].image
            let image = try openai.decodeBase64Image(data)
            
            isLoading.toggle()
            return image
        } catch {
            print(String(describing: error))
            isLoading.toggle()
            return nil
        }
    }
    
    // MARK: - Sending Messages APIs -
    
    func detectLanguage(for text: String) -> String {
        let tagger = NSLinguisticTagger(tagSchemes: [.language], options: 0)
        tagger.string = text
        let lang = tagger.dominantLanguage ?? "und" // und means undefined
        return lang
    }
    
    func sendMessage() {
        isLoading.toggle()
        let newMessage = Message(id: UUID().uuidString, content: currentInput, createdAt: getSessionDate(), role: .user)
        let userLang = detectLanguage(for: currentInput)
        msgsArr.append(Message(
            id: UUID().uuidString,
            content: """
            Your role is to interpret dreams.
            Respond only in the language of the input, which is \(userLang).
            Do not ask questions or provide any content beyond the interpretation of the dream.
            Treat whatever the user inputs as a dream description and provide an interpretation.
            """,
            createdAt: getSessionDate(),
            role: .system))
        msgsArr.append(newMessage)
        
        openAIService.sendStreamMessages(messages: msgsArr).responseStreamString { [weak self] stream in
            guard let self = self else { return }
            switch stream.event {
            case .stream(let response):
                switch response {
                case .success(let string):
                    let streamResponse = self.parseStreamData(string)
                    DispatchQueue.main.async {
                        streamResponse.forEach { newMessageResponse in
                            guard let messageContent = newMessageResponse.choices.first?.delta.content else {
                                return
                            }
                            guard let existingMessageIndex = self.msgsArr.lastIndex(where: {$0.id == newMessageResponse.id}) else {
                                let newMessage = Message(
                                    id: newMessageResponse.id,
                                    content: messageContent,
                                    createdAt: self.getSessionDate(),
                                    role: .assistant
                                )
                                self.msgsArr.append(newMessage)
                                return
                            }
                            let newMessage = Message(
                                id: newMessageResponse.id,
                                content: self.msgsArr[existingMessageIndex].content + messageContent,
                                createdAt: self.getSessionDate(),
                                role: .assistant
                            )
                            self.msgsArr[existingMessageIndex] = newMessage
                        }
                    }
                case .failure(_):
                    DispatchQueue.main.async {
                        self.isLoading.toggle()
                    }
                    print("/ChatVM/sendMessage/sendStreamMessage/Failure")
                }
            case .complete(_):
                DispatchQueue.main.async {
                    self.isLoading.toggle()
                }
                print("COMPLETE")
            }
        }
    }
    
    //MARK: - Firebase Functions -
    
    func storeMessageInFirebase() {
        guard let message = msgsArr.last else { return }
        guard let image = dreamInterpretedImage else { return }
        let storageRef = Storage.storage().reference()
        let imageData = image.jpegData(compressionQuality: 0.5)
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        guard let imageData = imageData else { return }
        
        let path = "Images/\(UUID().uuidString)"
        let fileRef = storageRef.child(path)
        let uploadTask = fileRef.putData(imageData, metadata: metadata)
        
        uploadTask.observe(.progress) { snapshot in
            print("In progress")
        }
        
        uploadTask.observe(.success) { snapshot in
            fileRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Handle error appropriately
                    return
                }
                self.uploadMessages(message: message, image: String(describing: downloadURL))
            }
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as? NSError {
                switch StorageErrorCode(rawValue: error.code) {
                case .objectNotFound:
                    self.errorMessage = "File doesn't exist"
                case .unauthorized:
                    self.errorMessage = "User doesn't have permission to access the file"
                case .cancelled:
                    self.errorMessage = "User canceled the upload"
                case .unknown:
                    self.errorMessage = "Unknown error occurred"
                default:
                    self.errorMessage = "A separate error occurred. This is a good place to retry the upload."
                }
            }
        }
        
    }
    
    func uploadMessages(message: Message, image: String) {
        
        let dateString = Utilities.formatDateAndTime(message.createdAt)
        let messageObj: [String: Any] = ["image": image, "interpretedText": message.content, "inputText": currentInput, "tags": tags]
        
        let query = db.collection("messages")
            .whereField("date", isEqualTo: dateString)
            .whereField("user", isEqualTo: SessionManager.shared.currentUser?.email ?? "")
        
        query.getDocuments { (querySnapshot, error) in
            if let document = querySnapshot?.documents.first {
                let documentRef = document.reference
                documentRef.updateData([
                    "messages": FieldValue.arrayUnion([messageObj])
                ])
            } else {
                let newDocumentData: [String: Any] = [
                    "user": SessionManager.shared.currentUser?.email ?? "",
                    "date": dateString,
                    "message": messageObj
                ]
                self.db.collection("messages").document(dateString).setData(newDocumentData) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added with ID: \(newDocumentData)")
                    }
                }
            }
        }
        
    }
    
    func decrementMaxTriesCount() {
        if let uid = SessionManager.shared.currentUser?.uid {
            
            let documentReference = db.collection("user-info").document(uid)
            documentReference.getDocument { document, error in
                
                if let document = document, document.exists {
                    if var maxTries = document.data()?["maxTries"] as? Int, maxTries > 0 {
                        maxTries -= 1
                        documentReference.updateData(["maxTries": maxTries]) { error in }
                    }
                }
                
            }
        }
    }
    
    
    // MARK: - HELPER FUNCTIONS -
    
    func scrollToBottom(proxy: ScrollViewProxy) {
        guard let id = msgsArr.filter({$0.role != .system}).last?.id else { return }
        proxy.scrollTo(id, anchor: .bottomTrailing)
    }
    
    func parseStreamData(_ data: String) -> [ChatStreamCompletionResponse] {
        let responseString = data.split(separator: "data:").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)}).filter({!$0.isEmpty})
        let jsonDecoder = JSONDecoder()
        
        return responseString.compactMap { jsonString in
            guard let jsonData = jsonString.data(using: .utf8), let streamResponse = try? jsonDecoder.decode(ChatStreamCompletionResponse.self, from: jsonData) else {
                return nil
            }
            return streamResponse
        }
    }
    
    func getSessionDate() -> Date {
        if msgsArr.isEmpty {
            UserDefaults.standard.sessionDate = selectedDate
            return UserDefaults.standard.sessionDate
        } else {
            return msgsArr[0].createdAt
        }
    }
    
    
}
