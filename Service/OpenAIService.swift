//
//  OpenAIService.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 10/08/2023.
//

import Foundation
import Alamofire
import Combine

class OpenAIService {
    let baseURL = "https://api.openai.com/v1/chat/completions"

    func sendMessage(messages: [Message]) async -> OpenAIChatResponse? {
        
        let openAIMappedMessages = messages.map({OpenAIChatMessage(role: $0.role, content: $0.content)})
        let body = OpenAIChatBody(model: "gpt-3.5-turbo", messages: openAIMappedMessages, stream: false, maxTokens: 450)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(Constants.apiKey.rawValue)"
        ]
        
        return try? await AF.request(baseURL, method: .post, parameters: body, encoder: .json, headers: headers).serializingDecodable(OpenAIChatResponse.self).value

    }

    func sendStreamMessages(baseURL: String) -> DataStreamRequest {
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(Constants.apiKey.rawValue)"
        ]
        
        return AF.streamRequest(baseURL, method: .get, headers: headers)

    }
}


