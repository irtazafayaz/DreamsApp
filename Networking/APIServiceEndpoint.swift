//
//  APIServiceEndpoint.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 08/09/2023.
//

import Foundation
import Alamofire

enum ApiServiceEndPoint: String, CaseIterable, Identifiable {
        
    case register = "signup"
    case login = ""
    case forgotPassword = "forgot-password"
    case logout = "logout"
    case ocr = "ocr"
    case gptText = "chatgpt-text"
    
    var id: String { rawValue }
    var description: String {
        switch self {
        case .register:
            return "Register User"
        case .login:
            return "Login User"
        case .logout:
            return "Logout User"
        case .ocr:
            return "Image"
        case .gptText:
            return "GPT text"
        case .forgotPassword:
            return "Forgot Password"
        }
    }
}

enum ApiError: Error, CustomNSError {
    
    case apiError
    case invalidEndPoint
    case invalidResponse
    case noData
    case serializationError
    
    var localizedDescription: String {
        switch self {
        case .apiError: return "Failed to fetch data"
        case .invalidEndPoint: return "Invlaid EndPoint"
        case .invalidResponse: return "Invalid response"
        case .noData: return "No data"
        case .serializationError: return "Failed to decode data"
        }
    }
}



struct NetworkError: Error {
    let apiError: AFError
    let backendError: BackendError?
}

struct BackendError: Error, Decodable {
    let status: String
    let message: String
}
