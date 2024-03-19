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
    
    @Published var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @Published var updateSessionID = true

    private let openAIService = OpenAIService()
    private let service = BaseService.shared
    private let db = Firestore.firestore()
    private let cancellables: Set<AnyCancellable> = []
    
    init(with text: String, messages: [Message] = [], selectedDate: Date = .now) {
        currentInput = text
        self.msgsArr = messages
        self.selectedDate = selectedDate
    }
    
    // MARK: - Sending Messages APIs -
    
    func sendMessage() {
        let newMessage = Message(id: UUID().uuidString, content: currentInput, createdAt: getSessionDate(), role: .user)
        uploadMessages(message: newMessage)
        msgsArr.append(newMessage)
        currentInput = ""
        
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
                    print("/ChatVM/sendMessage/sendStreamMessage/Failure")
                }
            case .complete(_):
                print("COMPLETE")
                if let serverMsg = msgsArr.last {
                    uploadMessages(message: serverMsg)
                }
            }
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
            "createdAt": message.createdAt,
            "userEmail": UserDefaults.standard.userEmail
        ]
        db.collection("messages").document().setData(documentObj) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
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
