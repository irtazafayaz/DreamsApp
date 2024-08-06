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
    @Published var interpretedDreams = [FirebaseDreams]()
    
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
    
    func fetchInterpretedDreams() {
        interpretedDreams.removeAll()
        
        guard let email = currentUser?.email else {
            return
        }
        
        database.collection("messages")
            .whereField("user", isEqualTo: email)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                if error != nil {
                    return
                } else {
                    self.interpretedDreams.removeAll() 
                    
                    for document in querySnapshot!.documents {
                        do {
                            let messageData = try document.data(as: FirebaseDreams.self)
                            self.interpretedDreams.append(messageData)
                            
                        } catch {
                            print("Error decoding to FirebaseDreams")
                        }
                    }
                    isLoading = false
                    print("interpretedDreams: \(interpretedDreams)")
                }
            }
    }

    
    func removeFirstMessage() {
        guard !interpretedDreams.isEmpty else {
            print("No interpreted dreams to remove.")
            return
        }
        
        interpretedDreams.sort { $0.date < $1.date }
        
        let removedDream = interpretedDreams.removeFirst()
        
        database.collection("messages").whereField("user", isEqualTo: currentUser?.email ?? "")
            .whereField("date", isEqualTo: removedDream.date)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error finding document to delete: \(error)")
                } else if let documents = querySnapshot?.documents, let document = documents.first {
                    document.reference.delete { error in
                        if let error = error {
                            print("Error deleting document: \(error)")
                        } else {
                            print("Document successfully deleted.")
                        }
                    }
                }
            }
    }

    
    
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    completion(.failure(error))
                    return
                }
                self.currentUser = Auth.auth().currentUser
                self.isSignedIn = true
                if let user = self.currentUser {
                    Purchases.shared.logIn(user.uid) { _, _, _ in
                        self.updateSubscriptionStatus()
                    }
                }
                completion(.success(()))
            }
        }
    }

    func register(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    completion(.failure(error))
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
                completion(.success(()))
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
    
    func deleteUserAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = currentUser else {
            completion(.failure(NSError(domain: "No user is currently signed in.", code: 401, userInfo: nil)))
            return
        }
        
        // Delete user data from Firestore
        let userRef = database.collection("users-info").document(user.uid)
        userRef.delete { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Delete user from Firebase Authentication
            user.delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    DispatchQueue.main.async {
                        self.currentUser = nil
                        self.isSignedIn = false
                        self.resetSubscriptionStatus()
                        
                    }
                    completion(.success(()))
                }
            }
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

