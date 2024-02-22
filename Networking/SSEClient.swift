////
////  SSEClient.swift
////  AiChatBot
////
////  Created by Irtaza Fiaz on 27/09/2023.
////
//
//import Foundation
//
//class SSEClient: ObservableObject {
//    @Published var receivedMessage: String = ""
//
//    private var eventSource: EventSource?
//
//    init() {
//        establishSSEConnection()
//    }
//
//    func establishSSEConnection() {
//        if let url = URL(string: "http://your-server-url/chat-stream") {
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//            let chatHistory: [[String: String]] = [
//                ["role": "user", "content": "Hi"],
//                ["role": "assistant", "content": "Hello! How can I assist you today?"],
//                ["role": "user", "content": "how much population of world"]
//            ]
//
//            let requestData: [String: Any] = ["chat_history": chatHistory]
//
//            do {
//                request.httpBody = try JSONSerialization.data(withJSONObject: requestData, options: [])
//            } catch {
//                print("Error encoding JSON: \(error)")
//                return
//            }
//
//            eventSource = EventSource(request: request)
//
//            eventSource?.connect()
//        }
//    }
//
//
//}
//
