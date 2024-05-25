//
//  SessionManager.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 26/05/2024.
//

import Foundation
import SwiftUI
import FirebaseAuth
import RevenueCat

class SessionManager: ObservableObject {
    
    static let shared = SessionManager()
    
    @Published var currentUser: User?
    @Published var isSignedIn = false
    @Published var isSubscribed = false

    private init() {
        self.currentUser = Auth.auth().currentUser
        self.isSignedIn = self.currentUser != nil
        if let user = self.currentUser {
            Purchases.shared.logIn(user.uid) { customerInfo, created, error in
                self.updateSubscriptionStatus()
            }
        }
    }

    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
            } else {
                self.currentUser = Auth.auth().currentUser
                self.isSignedIn = true
                if let user = self.currentUser {
                    Purchases.shared.logIn(user.uid) { customerInfo, created, error in
                        self.updateSubscriptionStatus()
                    }
                }
            }
        }
    }

    func register(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Error signing up: \(error.localizedDescription)")
            } else {
                self.currentUser = Auth.auth().currentUser
                self.isSignedIn = true
                if let user = self.currentUser {
                    Purchases.shared.logIn(user.uid) { customerInfo, created, error in
                        self.updateSubscriptionStatus()
                    }
                }
            }
        }
    }

    func logout() async {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
            self.isSignedIn = false
            self.resetSubscriptionStatus()
            _ = try await Purchases.shared.logOut()
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    
    func updateSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { customerInfo, error in
            if let error = error {
                print("Error fetching customer info: \(error.localizedDescription)")
            } else if let customerInfo = customerInfo {
                self.isSubscribed = customerInfo.entitlements.all["pro"]?.isActive == true
            }
        }
    }
    
    func resetSubscriptionStatus() {
        self.isSubscribed = false
    }
    
}
