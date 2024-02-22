//
//  ResponseMode;.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 08/09/2023.
//

import Foundation

struct RegisterResponse: Decodable {
    let message: String
}

struct LoginResponse: Decodable {
    let refreshToken: String
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct OCRResponse: Decodable {
    let gptResponse: String?
    let latexCode: String?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case gptResponse = "ChatGPT Response"
        case latexCode = "Latex Code"
        case error = "error"
    }
}

struct GPTTextResponse: Decodable {
    let gptResponse: String

    enum CodingKeys: String, CodingKey {
        case gptResponse = "ChatGPT Response"
    }
}
