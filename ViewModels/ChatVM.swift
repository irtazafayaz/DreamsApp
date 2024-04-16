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
    
    // MARK: Toggles
    @Published var isLoading: Bool = false
    @Published var isPaywallPresented = false
    
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
            storeMessageInFirebase(image)
            isLoading.toggle()
            return image
        } catch {
            print(String(describing: error))
            isLoading.toggle()
            return nil
        }
    }
    
    // MARK: - Sending Messages APIs -
    
    func sendMessage() {
        isLoading.toggle()
        let newMessage = Message(id: UUID().uuidString, content: currentInput, createdAt: getSessionDate(), role: .user)
        msgsArr.append(newMessage)
        openAIService.sendStreamMessages(messages: msgsArr).responseStreamString { [weak self] stream in
            
            guard let self = self else { return }
            switch stream.event {
            case .stream(let response):
                switch response {
                case .success(let string):
                    let streamResponse = self.parseStreamData(string)
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
                case .failure(_):
                    isLoading.toggle()
                    print("/ChatVM/sendMessage/sendStreamMessage/Failure")
                }
            case .complete(_):
                isLoading.toggle()
                print("COMPLETE")
            }
        }
    }
    
    //MARK: - Firebase Functions -
    
    func storeMessageInFirebase(_ image: UIImage) {
        guard let message = msgsArr.last else { return }
        
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
        let userEmail = UserDefaults.standard.string(forKey: "user-email") ?? "NaN"
        let messageObj: [String: Any] = ["image": image, "interpretedText": message.content]
        
        let query = db.collection("messages")
            .whereField("date", isEqualTo: dateString)
            .whereField("user", isEqualTo: userEmail)
        
        query.getDocuments { (querySnapshot, error) in
            if let document = querySnapshot?.documents.first {
                let documentRef = document.reference
                documentRef.updateData([
                    "messages": FieldValue.arrayUnion([messageObj])
                ])
            } else {
                let newDocumentData: [String: Any] = [
                    "user": userEmail,
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
