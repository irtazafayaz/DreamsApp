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
    @Published var selectedDate: DayComponents?
    
    @Published var selectedMessage: FirebaseMessages?
    @Published var groupedMessages = [FirebaseMessages]()
    @Published var isLoading: Bool = false

    
    @Published var filteredChats: [FirebaseMessages] = []
    var allChats: [String] = []
    
    var createdAtDates: [Date] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let uniqueDateStrings = Set(groupedMessages.map { $0.date }).sorted()
        let dates = uniqueDateStrings.compactMap { dateFormatter.date(from: $0) }.sorted()
        return dates
    }
    
    private let db = Firestore.firestore()
    
    func fetchMessagesGroupedByCreatedAt(email: String) {
        isLoading.toggle()
        groupedMessages.removeAll()
        
        db.collection("messages")
            .whereField("user", isEqualTo: email)
            .getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                if error != nil {
                    isLoading.toggle()
                    return
                } else {
                    for document in querySnapshot!.documents {
                        do {
                            let messageData = try document.data(as: FirebaseMessages.self)
                            self.groupedMessages.append(messageData)
                            
                        } catch {
                            print("Error decoding to FirebaseMessages")
                        }
                    }
                    isLoading.toggle()
                    print("Grouped Messages: \(groupedMessages)")
                }
            }
        
    }
    
    
    func setSelectedMsgs(_ selectedDate: Date) {
        let date = Utilities.formatDateAndTime(selectedDate)
        guard let message = groupedMessages.first(where: { $0.date == date }) else { return }
        selectedMessage = message
    }
    
    func searchChats(query: String) {
        if query.isEmpty {
            filteredChats = []
        } else {
            filteredChats = groupedMessages.filter {
                $0.message.interpretedText.lowercased().contains(query.lowercased()) 
                || ($0.message.inputText?.lowercased().contains(query.lowercased()) ?? false)
                || ($0.message.tags?.contains { $0.lowercased().contains(query.lowercased()) } ?? false)
            }
        }
    }
    
}
