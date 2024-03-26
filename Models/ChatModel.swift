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

struct Message: Decodable {
    let id: String
    let content: String
    let createdAt: Date
    let role: SenderRole
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

struct MessageContent: Codable {
    let image: String
    let interpretedText: String
    let prompt: String
}

struct FirebaseMessages: Identifiable, Codable {
    @DocumentID var id: String?
    let date: String
    let message: MessageContent
    let user: String
}
