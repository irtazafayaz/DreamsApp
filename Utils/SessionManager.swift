//
//  SessionManager.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 18/03/2024.
//

import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth

enum AuthState {
    case login
    case home(User)
}

final class SessionManager: ObservableObject {
    
    @Published var authState: AuthState = .login
    @Published var user: User?
    
    init() {
        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            guard let self = self else { return }
            if let firebaseUser = user {
                self.user = firebaseUser
                self.authState = .home(firebaseUser)
            } else {
                self.user = nil
                self.goToLoginPage()
            }
        }
    }
    
    func getCurrentAuthUser() {
        if let user = Auth.auth().currentUser {
            authState = .home(user)
        } else {
            authState = .login
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

    
    func goToLoginPage() {
        DispatchQueue.main.async {
            self.authState = .login
        }
    }
}
