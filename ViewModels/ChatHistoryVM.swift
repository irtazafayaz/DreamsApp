//
//  ChatHistoryVM.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 12/03/2024.
//

import Foundation
import FirebaseFirestore

class ChatHistoryVM: ObservableObject {
    
    @Published var createdAtDates: [String] = []
    
    func fetchMessagesGroupedByCreatedAt(completion: @escaping ([String: [FirebaseMessages]]) -> Void) {
        createdAtDates.removeAll()
        let db = Firestore.firestore()
        let messagesRef = db.collection("messages")

        var groupedMessages = [String: [FirebaseMessages]]()

        let dispatchGroup = DispatchGroup()

        messagesRef.getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }

            for document in documents {
                if let message = try? document.data(as: FirebaseMessages.self) {
                    dispatchGroup.enter()
                    let createdAt = message.createdAt
                    self.createdAtDates.append(createdAt)
                    if var messagesArray = groupedMessages[createdAt] {
                        messagesArray.append(message)
                        groupedMessages[createdAt] = messagesArray
                    } else {
                        groupedMessages[createdAt] = [message]
                    }
                    dispatchGroup.leave()
                }
            }
            dispatchGroup.notify(queue: .main) {
                completion(groupedMessages)
            }
        }
    }
    
}
