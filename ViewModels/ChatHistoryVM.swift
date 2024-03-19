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
        
    var createdAtDates: [Date] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let uniqueDateStrings = Set(groupedMessages.map { $0.date }).sorted()
        let dates = uniqueDateStrings.compactMap { dateFormatter.date(from: $0) }.sorted()
        return dates
    }
    
    @Published var selectedDate: DayComponents?
    
    @Published var selectedMessages: [Message] = []
    @Published var groupedMessages = [FirebaseMessages]()
    @Published var isLoading: Bool = false

    private let db = Firestore.firestore()
    
    func fetchMessagesGroupedByCreatedAt() {
        isLoading.toggle()
        groupedMessages.removeAll()
        
        db.collection("messages").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            guard let documents = querySnapshot?.documents else { return }
            
            
            let allMessages = documents.compactMap { document -> FirebaseMessages? in
                try? document.data(as: FirebaseMessages.self)
            }
            groupedMessages = allMessages
            isLoading.toggle()
            print("Grouped Messages\n \(groupedMessages)")
        }
    }
    
    
    func setSelectedMsgs(_ selectedDate: Date) {
        selectedMessages.removeAll()
        let date = Utilities.formatDateAndTime(selectedDate)
        guard let message = groupedMessages.first(where: { $0.date == date }) else { return }
        convertDataToMessagesArray(message: message)
    }
    
    
    func convertDataToMessagesArray(message: FirebaseMessages) {
        guard let date = Utilities.convertToDate(message.date) else { return }
        selectedMessages = message.messages.map {
            Message(
                id: UUID().uuidString,
                content: $0.content,
                createdAt: date,
                role: $0.role
            )
        }
        print("Selected Messages \(selectedMessages)")
    }
    
}
