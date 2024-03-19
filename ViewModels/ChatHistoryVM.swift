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
    
    @Published var moveToChatScreen: Bool = false
    @Published var fromChatHistory: Bool = true
    
    @Published var createdAtDates: [Date] = []
    @Published var selectedDate: DayComponents?

    @Published var selectedMessages: [Message] = []
    @Published var groupedMessages = [Date: [FirebaseMessages]]()
    
    private let db = Firestore.firestore()
    
    func fetchMessagesGroupedByCreatedAt(completion: @escaping ([Date: [FirebaseMessages]]) -> Void) {
        createdAtDates.removeAll()
        groupedMessages.removeAll()
        let dispatchGroup = DispatchGroup()
        
        db.collection("messages").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            guard let documents = querySnapshot?.documents else { return }
            for document in documents {
                dispatchGroup.enter()

                if let message = try? document.data(as: FirebaseMessages.self) {
                    let createdAt = message.createdAt
                    self.createdAtDates.append(createdAt)
                    if var messagesArray = self.groupedMessages[createdAt] {
                        messagesArray.append(message)
                        self.groupedMessages[createdAt] = messagesArray
                    } else {
                        self.groupedMessages[createdAt] = [message]
                    }
                }

                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                // Sort the messages within each group by createdAt date
                for (date, messages) in self.groupedMessages {
                    let sortedMessages = messages.sorted { $0.createdAt > $1.createdAt }
                    self.groupedMessages[date] = sortedMessages
                }
                
                self.createdAtDates = Array(self.groupedMessages.keys).sorted(by: >)
                completion(self.groupedMessages)
            }
        }
    }

    
    func setSelectedMsgs(_ selectedDate: Date?) {
        selectedMessages.removeAll()
        guard let selectedDate = selectedDate else { return }
        
        let calendar = Calendar.current
        let selectedDateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        
        for (dateKey, msgs) in groupedMessages {
            let dateKeyComponents = calendar.dateComponents([.year, .month, .day], from: dateKey)
            if dateKeyComponents == selectedDateComponents {
                convertDataToMessagesArray(msgs: msgs)
                break
            }
        }
    }

    
    func convertDataToMessagesArray(msgs: [FirebaseMessages]) {
        if !msgs.isEmpty {
            selectedMessages = msgs.map {
                Message(
                    id: UUID().uuidString,
                    content: $0.content,
                    createdAt: $0.createdAt ,
                    role: SenderRole(rawValue: $0.role) ?? .paywall
                )
            }
        }
    }
    
}
