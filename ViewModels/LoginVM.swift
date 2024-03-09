//
//  LoginVM.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 09/03/2024.
//

import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth

class LoginVM: ObservableObject {
    
    fileprivate var currentNonce: String?
    @Published var isLoginSuccessful: Bool = false
    
    func handleSignWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
    }
    
    func handleSignWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        if case .failure(let failure) = result {
            print("SHOW ERROR \(failure)")
        } else if case .success(let success) = result {
            if let appleIdCredentials = success.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    fatalError("Invalid Nonce")
                }
                guard let identifyToken = appleIdCredentials.identityToken else {
                    print("No Identify Token")
                    return
                }
                guard let tokenString = String(data: identifyToken, encoding: .utf8) else {
                    print("Unable to serialize token")
                    return
                }
                
                let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
                
                Task {
                    do {
                        let result = try await Auth.auth().signIn(with: credential)
                        if let email = result.user.email {
                            UserDefaults.standard.set(result.user.email, forKey: "user-email")
                            isLoginSuccessful.toggle()
                        }
                        print("SUCESSSSSSSS \(result)")
                    } catch {
                        print("signin failed")
                    }
                }
                
            }
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }
      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      let nonce = randomBytes.map { byte in
        charset[Int(byte) % charset.count]
      }
      return String(nonce)
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }

        

        
    
}
