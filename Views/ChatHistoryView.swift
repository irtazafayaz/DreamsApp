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
        VStack(alignment: .leading) {
            Text("Select Date")
                .font(Font.custom(FontFamily.bold.rawValue, size: 30))
                .foregroundColor(Color(hex: Colors.labelDark.rawValue))
                .padding(.leading, 20)
                .padding(.top, 20)
                .padding(.bottom, 5)
            
            Text("Choose the date you want to see your interpretations from :")
                .font(Font.custom(FontFamily.regular.rawValue, size: 18))
                .foregroundColor(Color(hex: Colors.labelDark.rawValue))
                .padding(.leading, 20)
                .padding(.bottom, 40)

            CalendarWidget(moveToChatScreen: $moveToChatScreen, selectedDate: $selectedDate)
            
            Spacer()
        }
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
