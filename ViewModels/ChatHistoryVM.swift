//
//  ChatHistoryVM.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 12/03/2024.
//

import Foundation
import FirebaseFirestore
import HorizonCalendar

class ChatHistoryVM: ObservableObject {
    
    @Published var createdAtDates: [Date] = []
    @Published var moveToChatScreen: Bool = false
    @Published var fromChatHistory: Bool = true
    @Published var selectedMessages: [Message] = []
    @Published var selectedDate: DayComponents?
    @Published var refreshCalendar: Bool = false


    func fetchMessagesGroupedByCreatedAt(completion: @escaping ([Date: [FirebaseMessages]]) -> Void) {
        self.refreshCalendar.toggle()
        let db = Firestore.firestore()
        let messagesRef = db.collection("messages")
        var groupedMessages = [Date: [FirebaseMessages]]()
        let dispatchGroup = DispatchGroup()
        messagesRef.getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(String(describing: error))")
                return
            }
            self.createdAtDates.removeAll()
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
                self.refreshCalendar.toggle()  
                completion(groupedMessages)
            }
        }
    }
    
}
