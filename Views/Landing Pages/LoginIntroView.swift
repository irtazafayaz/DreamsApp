//
//  LoginIntroView.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 25/05/2023.
//

import SwiftUI

struct LoginIntroView: View {
    
    @State private var isLoginViewPresented = false
    @State private var showLoginPage: Bool = false
    
    var body: some View {
            VStack {
                Image(AppImages.loginIntro.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 400)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            gradient: Gradient(
                                colors: [Color.clear, Color.white.opacity(1)]
                            ),
                            startPoint: .center,
                            endPoint: .bottom
                        )
                    )
                
                Text("The best AI Chatbot app in this century")
                    .font(Font.custom(FontFamily.bold.rawValue, size: 32))
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("Help Solve your HomeWork in minutes")
                    .font(Font.custom(FontFamily.regular.rawValue, size: 18))
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
                
                NavigationLink(destination: LoginRegisterSelectionView()) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 100)
                            .foregroundColor(Color(hex: Colors.primary.rawValue))
                            .shadow(color: Color.green.opacity(0.25), radius: 24, x: 4, y: 8)
                            .frame(height: 65)
                            .padding()
                        
                        Text("Continue")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .bold))
                    }
                }
                .padding(.bottom, 10)
                
            }
            .background(Color.white)
        
    }
}

struct LoginIntroView_Previews: PreviewProvider {
    static var previews: some View {
        LoginIntroView()
    }
}

