//
//  ChatVM.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 06/06/2023.
//

import Foundation
import SwiftUI
import Combine
import CoreData
import Alamofire

class ChatVM: ObservableObject {
    
    @Published var messages: [Message] = []
    @Published var msgsArr: [MessageWithImages] = []
    @Published var currentInput: String = ""
    @Published var scrollToTop: Bool = false
    @Published var isInteracting = false
    @Published var updateSessionID = true
    
    @FetchRequest(sortDescriptors: []) var chatHistory: FetchedResults<ChatHistory>
    private let openAIService = OpenAIService()
    private let service = BaseService.shared
    
    init(with text: String, messages: [MessageWithImages] = []) {
        currentInput = text
        self.msgsArr = messages
    }
    
    // MARK: Send Message APIs
    
    func sendImage(image: UIImage, completion: @escaping (MessageWithImages?) -> Void) {
        UserDefaults.standard.maxTries += 1
        service.ocrWithImage(from: .ocr, image: image, completion: { [weak self] response in
            print(response)
            guard let self = self else { return }
            switch response {
            case .success(let response):
                if let error = response.error {
                    completion(MessageWithImages(id: UUID().uuidString, content: .text(error), createdAt: Date(), role: .assistant, sessionID: self.getSession()))
                } else if let gpt = response.gptResponse {
                    completion(MessageWithImages(id: UUID().uuidString, content: .text(gpt), createdAt: Date(), role: .assistant, sessionID: self.getSession()))
                } else {
                    completion(nil)
                }
            case .failure(_):
                completion(nil)
            }
        })
    }
    
    
    func sendMessageUsingFirebase(completion: @escaping (MessageWithImages?) -> Void) {
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
                let msg = MessageWithImages(id: UUID().uuidString, content: .text(response.gptResponse), createdAt: Date(), role: .assistant, sessionID: msgsArr[0].sessionID)
                self.msgsArr.append(msg)
                completion(msg)
            case .failure(let error):
                print("> GPT ERROR \(error)")
                completion(nil)
            }
        }
    }
    
    func sendUsingAlamofireStream() {
        
        guard let baseUrl = URL(string: "http://127.0.0.1:5000/chat-stream") else {
            return
        }
        let content = "please write 50 words response"
        let role = "user"
        let jsonParam = [[
            "content": content,
            "role": role
        ]]
        do {
            let messages = msgsArr.map { message in
                var messageDictionary: [String: Any] = [
                    "role": message.role.rawValue
                ]
                switch message.content {
                case .text(let text):
                    messageDictionary["content"] = text
                case .image(_):
                    messageDictionary["content"] = "image"
                }
                
                return messageDictionary
            }
            let jsonData = try JSONSerialization.data(withJSONObject: messages, options: [])
            let jsonDataString = String(data: jsonData, encoding: .utf8) ?? "{}"
            if let encodedJsonData = jsonDataString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                let urlString = "\(baseUrl)?chat_history=\(encodedJsonData)"
                
                let serverMsg = MessageWithImages(id: UUID().uuidString, content: .text(""), createdAt: Date(), role: .assistant, sessionID: getSession())
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
                            let newMsg = MessageWithImages(
                                id: serverMsg.id,
                                content: .text(getMsgContentText(self.msgsArr[existingMessageIndex].content) + newMessageResponse),
                                createdAt: serverMsg.createdAt,
                                role: .assistant,
                                sessionID: serverMsg.sessionID
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
            
    
    func getMsgContentText(_ msg: MessageContent) -> String {
        switch msg {
        case .text(let text):
            return text
        case .image(_):
            return "Image.png"
        }
    }
    
    func parseStreamData(_ data: String) -> String {
        let responseString = data.split(separator: "data:").map { String($0) }
        return responseString.isEmpty ? "" : responseString[0]
    }

    
    
    
    
    // MARK: HELPER FUNCTIONS
    
    func mapToMessages(_ messagesWithImages: [MessageWithImages]) -> [MessageData] {
        return messagesWithImages.map { messageWithImages in
            switch messageWithImages.content {
            case .text(let textContent):
                return MessageData(
                    id: messageWithImages.id,
                    role: messageWithImages.role,
                    content: textContent
                )
            case .image:
                return MessageData(
                    id: messageWithImages.id,
                    role: messageWithImages.role,
                    content: "Image Content"
                )
            }
        }
    }
    
    func getMessageObject() {
        if updateSessionID {
            if msgsArr.isEmpty {
                UserDefaults.standard.sessionID += 1
            }
            updateSessionID = false
        }
    }
    
    func getSession() -> Double {
        if msgsArr.isEmpty {
            UserDefaults.standard.sessionID += 1
            return Double(UserDefaults.standard.sessionID)
        } else {
            return msgsArr[0].sessionID
        }
    }
    
    func addUserMsg() -> MessageWithImages {
        let newMessage = MessageWithImages(id: UUID().uuidString, content: .text(currentInput), createdAt: Date(), role: .user, sessionID: getSession())
        currentInput = ""
        msgsArr.append(newMessage)
        UserDefaults.standard.maxTries += 1
        let typingMsg = MessageWithImages(id: UUID().uuidString, content: .text("typing..."), createdAt: Date(), role: .assistant, sessionID: getSession())
        msgsArr.append(typingMsg)
        return newMessage
    }
    
}
