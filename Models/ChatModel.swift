//
//  ChatModel.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 06/06/2023.
//

import Foundation

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

enum SenderRole: String, Codable {
    case system
    case user
    case assistant
    case paywall
}

struct OpenAIChatResponse: Decodable {
    let choices: [OpenAIChatChoice]
}

struct OpenAIChatChoice: Decodable {
    let message: OpenAIChatMessage
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

enum Role: String, Codable {
    case system
    case user
    case assistant
    case paywall
}

struct Message: Decodable {
    let id: String
    let content: String
    let createdAt: Date
    let role: SenderRole
}

struct MessageWithImages {
    let id: String
    let content: MessageContent
    let createdAt: Date
    let role: SenderRole
    let sessionID: Double
    
    init(id: String, content: MessageContent, createdAt: Date, role: SenderRole, sessionID: Double) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
        self.role = role
        self.sessionID = sessionID
    }
    
}

enum MessageContent: Equatable {
    case text(String)
    case image(Data)

    static func == (lhs: MessageContent, rhs: MessageContent) -> Bool {
        switch (lhs, rhs) {
        case let (.text(leftText), .text(rightText)):
            return leftText == rightText
        case let (.image(leftImageData), .image(rightImageData)):
            return leftImageData == rightImageData
        default:
            return false
        }
    }
}

struct ChatStreamCompletionResponse: Decodable {
    let id: String
    let choices: [ChatStreamChoice]
}

struct ChatStreamChoice: Decodable {
    let delta: ChatStreamContent
}

struct ChatStreamContent: Decodable {
    let content: String?
}

struct User: Hashable {
    var name: String
    var avatar: String?
    var isCurrrentUser: Bool = false
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
