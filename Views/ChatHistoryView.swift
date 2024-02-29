//
//  ChatHistoryView.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 04/09/2023.
//

import SwiftUI
import HorizonCalendar

struct ChatHistoryView: View {
    
    @State private var moveToChatScreen: Bool = false
    @State private var fromChatHistory: Bool = true
    @State private var selectedMessages: [Message] = []
    @State var selectedDate: DayComponents?

    var body: some View {
        VStack {
            CalendarWidget(moveToChatScreen: $moveToChatScreen, selectedDate: $selectedDate)
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
