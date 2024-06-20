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
    
    @Published var selectedMessage: FirebaseDreams?
    @Published var isLoading: Bool = false

    
    @Published var filteredChats: [FirebaseDreams] = []
    var allChats: [String] = []
    
    var createdAtDates: [Date] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let uniqueDateStrings = Set(SessionManager.shared.interpretedDreams.map { $0.date }).sorted()
        let dates = uniqueDateStrings.compactMap { dateFormatter.date(from: $0) }.sorted()
        return dates
    }
    
    private let db = Firestore.firestore()
    
    func setSelectedMsgs(_ selectedDate: Date) {
        let date = Utilities.formatDateAndTime(selectedDate)
        guard let message = SessionManager.shared.interpretedDreams.first(where: { $0.date == date }) else { return }
        selectedMessage = message
    }
    
    func searchChats(query: String) {
        if query.isEmpty {
            filteredChats = []
        } else {
            filteredChats = SessionManager.shared.interpretedDreams.filter {
                $0.message.interpretedText.lowercased().contains(query.lowercased()) 
                || ($0.message.inputText?.lowercased().contains(query.lowercased()) ?? false)
                || ($0.message.tags?.contains { $0.lowercased().contains(query.lowercased()) } ?? false)
            }
        }
    }
    
}
