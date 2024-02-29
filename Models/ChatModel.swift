//
//  ChatModel.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 06/06/2023.
//

import Foundation
import FirebaseFirestore

struct OpenAIChatBody: Encodable {
    let model: String
    let messages: [OpenAIChatMessage]
    let stream: Bool
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model, messages, stream
        case maxTokens = "max_tokens"
    }
}

struct OpenAIChatMessage: Codable {
    let role: SenderRole
    let content: String
}

struct OpenAIChatResponse: Decodable {
    let choices: [OpenAIChatChoice]
}

struct OpenAIChatChoice: Decodable {
    let message: OpenAIChatMessage
}

enum SenderRole: String, Codable {
    case system
    case user
    case assistant
    case paywall
}

struct MessageData: Codable {
    let id: String
    let role: SenderRole
    let content: String
    
    var description: [String: Any] {
        let dictionary: [String: Any] = [
            "role": role.rawValue,
            "content": content
        ]
        return dictionary
    }
}

struct Message: Decodable {
    let id: String
    let content: String
    let createdAt: Date
    let role: SenderRole
}

struct DataSource {
    static let messages = [
        Message(id: UUID().uuidString, content: "Hi, I really love your templates and I would like to buy the chat template", createdAt: Date(), role: .user),
        Message(id: UUID().uuidString, content: "Hi, I really love your templates and I would like to buy the chat template", createdAt: Date(), role: .assistant),
        Message(id: UUID().uuidString, content: "Hi, I really love your templates and I would like to buy the chat template", createdAt: Date(), role: .user),
        Message(id: UUID().uuidString, content: "Hi, I really love your templates and I would like to buy the chat template", createdAt: Date(), role: .assistant),
        Message(id: UUID().uuidString, content: "Hi, I really love your templates and I would like to buy the chat template", createdAt: Date(), role: .user),
        Message(id: UUID().uuidString, content: "Hi, I really love your templates and I would like to buy the chat template", createdAt: Date(), role: .assistant),
    ]
}

struct FirebaseMessages: Identifiable, Codable {
    @DocumentID var id: String?
    let content: String
    let createdAt: Date
    let role: String
}
