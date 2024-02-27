//
//  ChatHistoryView.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 04/09/2023.
//

import SwiftUI

struct ChatHistoryView: View {
    

    @State private var moveToChatScreen: Bool = false
    @State private var fromChatHistory: Bool = true
    @State private var selectedMessages: [MessageWithImages] = []
    
    var body: some View {
        VStack {
           CalendarWidget()
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
