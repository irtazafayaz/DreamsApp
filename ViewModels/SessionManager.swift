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
import FirebaseFirestore


class SessionManager: ObservableObject {
    
    static let shared = SessionManager()
    
    @Published var currentUser: User?
    @Published var isSignedIn = false
    @Published var isSubscribed = false
    @Published var isLoading = false
    
    private let database = Firestore.firestore()

    private init() {
        self.currentUser = Auth.auth().currentUser
        self.isSignedIn = self.currentUser != nil
        if let user = self.currentUser {
            Purchases.shared.logIn(user.uid) { _, _, _ in
                self.updateSubscriptionStatus()
            }
        }
    }
    
    func getMaxTries(completion: @escaping (Int) -> Void) {
        guard let user = currentUser else {
            print("No user is currently signed in.")
            completion(0)
            return
        }
        
        let userRef = self.database.collection("users-info").document(user.uid)
        
        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting maxTries: \(error.localizedDescription)")
                completion(0)
            } else if let document = document, document.exists {
                let tries = document.data()?["maxTries"] as? Int ?? 0
                completion(tries)
            } else {
                print("Document does not exist.")
                completion(0)
            }
        }
    }

    
    func login(email: String, password: String) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    print("Error signing in: \(error.localizedDescription)")
                    return
                }
                self.currentUser = Auth.auth().currentUser
                self.isSignedIn = true
                if let user = self.currentUser {
                    Purchases.shared.logIn(user.uid) { _, _, _ in
                        self.updateSubscriptionStatus()
                    }
                }
            }
        }
    }

    func register(email: String, password: String) {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    print("Error signing up: \(error.localizedDescription)")
                    return
                }
                self.currentUser = Auth.auth().currentUser
                self.isSignedIn = true
                if let user = self.currentUser {
                    Purchases.shared.logIn(user.uid) { _, _, _ in
                        self.updateSubscriptionStatus()
                    }
                    self.database.collection("users-info").document(user.uid).setData(["maxTries": 10])
                }
            }
        }
    }

    func logout() async {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isSignedIn = false
                self.resetSubscriptionStatus()
            }
            _ = try await Purchases.shared.logOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    private func updateSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { customerInfo, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching customer info: \(error.localizedDescription)")
                    return
                }
                self.isSubscribed = customerInfo?.entitlements.all["pro"]?.isActive == true
            }
        }
    }
    
    private func resetSubscriptionStatus() {
        DispatchQueue.main.async {
            self.isSubscribed = false
        }
    }
}

