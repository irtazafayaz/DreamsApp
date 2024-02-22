//
//  BaseService.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 08/09/2023.
//

import Foundation
import Combine
import Alamofire
import UIKit

class BaseService: BaseActions {
    
    private init() {}
    static let shared = BaseService()
    
    private let urlSession = URLSession.shared
    private let jsonDecoder = Utilities.jsonDecoder
    
    func loadAndDecode<D: Decodable>(
        url: URL,
        params: [String: Any],
        method: HTTPMethod = .post,
        contentType: String = "application/json",
        completion: @escaping (Result<D, ApiError>) -> ()) {
            
            var headers: HTTPHeaders = ["Content-Type": contentType]
            if let refreshToken = params["refresh_token"] {
                headers["Authorization"] = "Bearer \(refreshToken)"
            }
            var p = params
            if method == .get {
                p = [:]
            }
            AF.request(url, method: method, parameters: p, encoding: method == .get ? URLEncoding.default : JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: D.self) { response in
                    switch response.result {
                    case .success(let value):
                        completion(.success(value))
                    case .failure(let error):
                        print("Request failed with error: \(error)")
                        if let data = response.data {
                            print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
                        }
                        completion(.failure(.apiError))
                    }
                }
        }
    
    func executeCompletionHandlerInMainThread<D: Decodable>(
        with result: Result<D, ApiError>,
        completion: @escaping (Result<D, ApiError>) -> ()) {
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
    
    func registerUser(
        from movieEndPoint: ApiServiceEndPoint,
        params: [String: String],
        completion: @escaping (Result<RegisterResponse, ApiError>) -> ()) {
            
            guard let url = URL(string: "\(URLs.baseURL)\(movieEndPoint.rawValue)") else {
                completion(.failure(.invalidEndPoint))
                return
            }
            self.loadAndDecode(url: url, params: params, completion: completion)
        }
    
    func login(
        from movieEndPoint: ApiServiceEndPoint,
        params: [String: String],
        completion: @escaping (Result<LoginResponse, ApiError>) -> ()) {
            
            guard let url = URL(string: "\(URLs.baseURL)\(movieEndPoint.rawValue)") else {
                completion(.failure(.invalidEndPoint))
                return
            }
            self.loadAndDecode(url: url, params: params, completion: completion)
        }
    
    func logout(
        from movieEndPoint: ApiServiceEndPoint,
        refreshToken: String,
        completion: @escaping (Result<RegisterResponse, ApiError>) -> ()) {
            
            guard let url = URL(string: "\(URLs.baseURL)\(movieEndPoint.rawValue)") else {
                completion(.failure(.invalidEndPoint))
                return
            }
            self.loadAndDecode(url: url, params: ["refresh_token": refreshToken], method: .get, completion: completion)
        }
    
    func ocrWithImage(
        from movieEndPoint: ApiServiceEndPoint,
        image: UIImage,
        completion: @escaping (Result<OCRResponse, ApiError>) -> ()) {
            
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                let url = URL(string: "\(URLs.baseURL)ocr")!
                let headers: HTTPHeaders = [
                    "Content-Type": "multipart/form-data"
                ]
                AF.upload(multipartFormData: { multipartFormData in
                    multipartFormData.append(imageData, withName: "image", fileName: "image.jpg", mimeType: "image/jpeg")
                }, to: url, method: .post, headers: headers)
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let ocrResponse = try JSONDecoder().decode(OCRResponse.self, from: data)
                            completion(.success(ocrResponse))
                        } catch {
                            completion(.failure(.serializationError))
                        }
                    case .failure(_):
                        completion(.failure(.apiError))
                    }
                }
            }
        }
    
    func askGPT(
        from movieEndPoint: ApiServiceEndPoint,
        history: [String : [[String : Any]]],
        completion: @escaping (Result<GPTTextResponse, ApiError>) -> ()) {
            
            guard let url = URL(string: "\(URLs.baseURL)\(movieEndPoint.rawValue)") else {
                completion(.failure(.invalidEndPoint))
                return
            }
            self.loadAndDecode(url: url, params: history, completion: completion)
        }
    
    func forgotPassword(
        from movieEndPoint: ApiServiceEndPoint,
        params: [String : String],
        completion: @escaping (Result<RegisterResponse, ApiError>) -> ()) {
            
            guard let url = URL(string: "\(URLs.baseURL)\(movieEndPoint.rawValue)") else {
                completion(.failure(.invalidEndPoint))
                return
            }
            self.loadAndDecode(url: url, params: params, completion: completion)
        }
    
    
    
    func streamText(
        from movieEndPoint: ApiServiceEndPoint,
        history: [String : [[String : Any]]],
        completion: @escaping (Result<GPTTextResponse, ApiError>) -> ()) {
        guard let url = URL(string: "http://127.0.0.1:5000/chat-stream") else {
            completion(.failure(.invalidEndPoint))
            return
        }
        self.loadAndDecode(url: url, params: history, contentType: "text/event-stream", completion: completion)
    }
    
}
