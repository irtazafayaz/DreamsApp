//
//  StartChatView.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 06/06/2023.
//

import SwiftUI

struct StartChatView: View {
    
    @State var isChatScreenPresented = false
    @Environment(\.managedObjectContext) var moc

    var body: some View {
        VStack {
            
            Image("ic_app_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding(.top, 30)
            
            Text("Welcome to")
                .font(Font.custom(FontFamily.bold.rawValue, size: 40))
                .foregroundColor(Color(hex: Colors.labelDark.rawValue))
                .padding(.top, 20)
            
            Text("Dreams App")
                .font(Font.custom(FontFamily.bold.rawValue, size: 40))
                .foregroundColor(Color(hex: Colors.primary.rawValue))
            
            Text("Start chatting with School AI now.\nYou can ask me anything.")
                .font(Font.custom(FontFamily.regular.rawValue, size: 18))
                .foregroundColor(Color(hex: Colors.labelGray.rawValue))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)
            
            Spacer()
            
            Button {
                isChatScreenPresented.toggle()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 100)
                        .foregroundColor(Color(hex: Colors.primary.rawValue))
                        .shadow(color: Color.green.opacity(0.25), radius: 24, x: 4, y: 8)
                        .frame(height: 65)
                        .padding()
                    
                    Text("Start Chat")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .bold))
                }
            }
            .padding(.bottom, 50)
        }
        .navigationDestination(isPresented: $isChatScreenPresented, destination: {
            ChatView()
        })
    }
}

struct StartChatView_Previews: PreviewProvider {
    static var previews: some View {
        StartChatView()
    }
}
