//
//  StartChatView.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 06/06/2023.
//

import SwiftUI

struct StartChatView: View {

    @Environment(\.managedObjectContext) var moc

    @State var isChatScreenPresented = false
    @State private var selectedDate = Date.now
    @State private var openDatePicker = false
    @State private var openErrorDialog = false

    var groupedMessages: [FirebaseMessages]

    var body: some View {
        VStack {
            
            Image("ic_app_logo_gray")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .foregroundColor(Color(hex: Colors.primary.rawValue))
                .padding(.top, 30)
            
            Text("Welcome to")
                .font(Font.custom(FontFamily.bold.rawValue, size: 40))
                .foregroundColor(Color(hex: Colors.labelDark.rawValue))
                .padding(.top, 20)
            
            Text("AI Dream Interpreter")
                .font(Font.custom(FontFamily.bold.rawValue, size: 40))
                .foregroundColor(Color(hex: Colors.primary.rawValue))
            
            Text("Start describing your dream. Don’t be afraid to ask me questions about your dreams!")
                .font(Font.custom(FontFamily.regular.rawValue, size: 18))
                .foregroundColor(Color(hex: Colors.labelGray.rawValue))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)
            
            Spacer()
            
            Button {
                openDatePicker.toggle()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 100)
                        .foregroundColor(Color(hex: Colors.primary.rawValue))
                        .shadow(color: Color.green.opacity(0.25), radius: 24, x: 4, y: 8)
                        .frame(height: 65)
                        .padding()
                    
                    Text("Enter your dream")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .bold))
                }
            }
            .padding(.bottom, 50)
            .sheet(isPresented: $openDatePicker) {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: ...Date.now, displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .presentationDetents([.medium])
                
                Button("Select Date") {
                    openDatePicker.toggle()
                    if !groupedMessages.contains(where: { $0.date == Utilities.formatDateAndTime(selectedDate) }) {
                        isChatScreenPresented.toggle()
                    } else {
                        openErrorDialog.toggle()
                    }
                }
                .padding()
            }
        }
        .alert("Already interpredted dream on this day", isPresented: $openErrorDialog, actions: {
            Button("OK", role: .cancel){}
        })
        .navigationDestination(isPresented: $isChatScreenPresented, destination: {
            ChatView(selectedDate: selectedDate)
        })
    }
}

