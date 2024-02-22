//
//  ChatHistoryView.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 04/09/2023.
//

import SwiftUI

struct ChatHistoryView: View {
    
    @FetchRequest(
        entity: ChatHistory.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \ChatHistory.createdAt, ascending: true)
        ],
        predicate: NSPredicate(format: "address == %@", UserDefaults.standard.loggedInEmail)
    ) var chatHistory: FetchedResults<ChatHistory>
     
    @Environment(\.managedObjectContext) var moc
    @State private var moveToChatScreen: Bool = false
    @State private var fromChatHistory: Bool = true
    @State private var selectedMessages: [MessageWithImages] = []
    
    var groupedItems: [(Double, [ChatHistory])] {
        let groupedDictionary = Dictionary(grouping: chatHistory) { item in
            return item.sessionID
        }
        return groupedDictionary.sorted { $0.key < $1.key }
    }
    
    var uniqueGroups: [Double] {
        let groupSet = Set(chatHistory.compactMap { $0.sessionID })
        let sortedChatHistory = groupSet.sorted { $0 > $1 }
        return Array(sortedChatHistory)
    }
    
    func representativeItem(forGroup group: Double) -> ChatHistory? {
        return chatHistory.last { $0.sessionID == group }
    }
    
    func convertDataToMessagesArray(forGroup group: Double) {
        let chatArr = chatHistory.filter { $0.sessionID == group }
        if !chatArr.isEmpty {
            selectedMessages = chatArr.map {
                MessageWithImages(
                    id: UUID().uuidString,
                    content: ($0.message != nil) ? .text($0.message ?? "NaN") : .image($0.imageData!),
                    createdAt: $0.createdAt ?? Date(),
                    role: SenderRole(rawValue: $0.role ?? "NaN") ?? .paywall,
                    sessionID: $0.sessionID
                )
            }
        }
    }
    
    var body: some View {
        VStack {
            if uniqueGroups.count == 0 {
                VStack(alignment: .center) {
                    Text("No History Found")
                }
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(uniqueGroups, id: \.self) { group in
                            if let chat = representativeItem(forGroup: group) {
                                Button {
                                    convertDataToMessagesArray(forGroup: group)
                                    moveToChatScreen.toggle()
                                } label: {
                                    ZStack {
                                        ChatHistoryCard(message: "\(chat.message ?? "Image")", date: Utilities.formatDate(chat.createdAt ?? Date()) )
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top, 20)
            }
        }
        .padding(.horizontal, 10)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $moveToChatScreen, destination: {
            ChatView(messagesArr: selectedMessages)
        })
    }
    
}

struct ChatHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ChatHistoryView()
    }
}
