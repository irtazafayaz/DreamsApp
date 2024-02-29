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

class ChatVM: ObservableObject {
    
    @Published var firebaseMsgs: [FirebaseMessages] = []
    @Published var msgsArr: [Message] = []
    @Published var currentInput: String = ""
    @Published var scrollToTop: Bool = false
    @Published var isEditing: Bool = false
    @Published var isPaywallPresented = false
    @Published var isAdShown = false
    @Published var selectedDate: Date = .now
    
    private let openAIService = OpenAIService()
    private let service = BaseService.shared
    private let db = Firestore.firestore()
    private let cancellables: Set<AnyCancellable> = []
    
    init(with text: String, messages: [Message] = [], selectedDate: Date = .now) {
        currentInput = text
        self.msgsArr = messages
        self.selectedDate = selectedDate
    }
    
    // MARK: - HELPER FUNCTIONS -
    
    func mapToMessages(_ messagesWithImages: [Message]) -> [MessageData] {
        return messagesWithImages.map { messageWithImages in
            return MessageData(
                id: messageWithImages.id,
                role: messageWithImages.role,
                content: messageWithImages.content
            )
        }
    }
    
    func scrollToBottom(proxy: ScrollViewProxy) {
        guard let id = msgsArr.filter({$0.role != .system}).last?.id else { return }
        proxy.scrollTo(id, anchor: .bottomTrailing)
    }
    
    func parseStreamData(_ data: String) -> String {
        let responseString = data.split(separator: "data:").map { String($0) }
        return responseString.isEmpty ? "" : responseString[0]
    }
    
    func addUserMsg() {
        let newMessage = Message(id: UUID().uuidString, content: currentInput, createdAt: Date(), role: .user)
        currentInput = ""
        msgsArr.append(newMessage)
        let typingMsg = Message(id: UUID().uuidString, content: "typing...", createdAt: Date(), role: .assistant)
        msgsArr.append(typingMsg)
        uploadMessages(message: newMessage)
    }
    
    // MARK: - Sending Messages APIs -
    
    func sendMessageToFirebase() {
        addUserMsg()
        
    }
    
    func sendMessageUsingFirebase(completion: @escaping (Message?) -> Void) {
        let filteredMsgs = mapToMessages(msgsArr)
        let messagesDescription = filteredMsgs.map { message in
            return message.description
        }
        let data = ["chat_history": messagesDescription]
        service.askGPT(from: .gptText, history: data) { [weak self] response in
            guard let self = self else { return }
            switch response {
            case .success(let response):
                _ = msgsArr.popLast()
                let msg = Message(id: UUID().uuidString, content: response.gptResponse, createdAt: Date(), role: .assistant)
                self.msgsArr.append(msg)
                completion(msg)
            case .failure(let error):
                print("> GPT ERROR \(error)")
                completion(nil)
            }
        }
    }
    
    func sendUsingAlamofireStream() {
        guard let baseUrl = URL(string: "http://127.0.0.1:5000/chat-stream") else { return }
        let content = "please write 50 words response"
        let role = "user"
        do {
            let messages = msgsArr.map { message in
                var messageDictionary: [String: Any] = [
                    "role": message.role.rawValue
                ]
                messageDictionary["content"] = message.content
                return messageDictionary
            }
            let jsonData = try JSONSerialization.data(withJSONObject: messages, options: [])
            let jsonDataString = String(data: jsonData, encoding: .utf8) ?? "{}"
            if let encodedJsonData = jsonDataString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                let urlString = "\(baseUrl)?chat_history=\(encodedJsonData)"
                
                let serverMsg = Message(id: UUID().uuidString, content: "", createdAt: Date(), role: .assistant)
                msgsArr.append(serverMsg)
                openAIService.sendStreamMessages(baseURL: urlString).responseStreamString { [weak self] stream in
                    guard let self = self else { return }
                    switch stream.event {
                    case .stream(let response):
                        switch response {
                        case .success(let string):
                            let newMessageResponse = parseStreamData(string)
                            guard let existingMessageIndex = self.msgsArr.lastIndex(where: {$0.role == .assistant}) else {
                                return
                            }
                            let newMsg = Message(
                                id: serverMsg.id,
                                content: self.msgsArr[existingMessageIndex].content + newMessageResponse,
                                createdAt: serverMsg.createdAt,
                                role: .assistant
                            )
                            self.msgsArr[existingMessageIndex] = newMsg
                        case .failure(_):
                            print("/ChatVM/sendMessage/sendStreamMessage/Failure")
                        }
                    case .complete(_):
                        print("COMPLETE")
                    }
                }
            }
        } catch {
            print("Error encoding JSON: \(error.localizedDescription)")
        }
    }
    
    //MARK: - Firebase Functions -
    
    func fetchFireBaseMessages() {
        db.collection("messages")
            .addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        print(document.data())
                    }
                    self.firebaseMsgs = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: FirebaseMessages.self)
                    } ?? []
                }
            }
    }
    
    func uploadMessages(message: Message) {
        let documentObj: [String: Any] = [
            "content": message.content,
            "role": message.role.rawValue,
            "createdAt": message.createdAt
        ]
        db.collection("messages").document().setData(documentObj) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    
}
