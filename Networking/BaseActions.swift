//
//  BaseActions.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 08/09/2023.
//

import Foundation
import UIKit

protocol BaseActions {
    
    func registerUser(
        from movieEndPoint: ApiServiceEndPoint,
        params: [String: String],
        completion: @escaping (Result<RegisterResponse, ApiError>) -> ()
    )
    
    func login(
        from movieEndPoint: ApiServiceEndPoint,
        params: [String: String],
        completion: @escaping (Result<LoginResponse, ApiError>) -> ()
    )
    
    func logout(
        from movieEndPoint: ApiServiceEndPoint,
        refreshToken: String,
        completion: @escaping (Result<RegisterResponse, ApiError>) -> ()
    )
    
    func ocrWithImage(
        from movieEndPoint: ApiServiceEndPoint,
        image: UIImage,
        completion: @escaping (Result<OCRResponse, ApiError>) -> ()
    )
    
    func askGPT(
        from movieEndPoint: ApiServiceEndPoint,
        history: [String : [[String : Any]]],
        completion: @escaping (Result<GPTTextResponse, ApiError>) -> ()
    )
    
    func forgotPassword(
        from movieEndPoint: ApiServiceEndPoint,
        params: [String: String],
        completion: @escaping (Result<RegisterResponse, ApiError>) -> ()
    )
    
}
