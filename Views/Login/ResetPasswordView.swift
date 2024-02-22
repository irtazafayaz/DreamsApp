//
//  ResetPasswordView.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 29/05/2023.
//

import SwiftUI

struct ResetPasswordView: View {
    
    @ObservedObject private var viewModel: ResetPasswordVM
    @Environment(\.presentationMode) var presentationMode

    init(viewModel: ResetPasswordVM) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            VStack (alignment: .leading) {
                Text("Reset your password 🔑")
                    .font(Font.custom(FontFamily.bold.rawValue, size: 32))
                    .frame(alignment: .leading)
                
                Text("Please enter your email and we will send an OTP code in the next step to reset your password.")
                    .font(Font.custom(FontFamily.regular.rawValue, size: 18))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 10)
                    .lineLimit(3)
                
                VStack(alignment: .leading) {
                    Text("Email")
                        .font(.headline)
                    HStack {
                        TextField("Email", text: $viewModel.email)
                        Image("ic_dropdown")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color(hex: Colors.primary.rawValue))
                            .frame(width: 20, height: 20)
                    }
                    .padding(.bottom, 20)
                    .underlinedTextFieldStyle()
                }
                .padding(.top, 20)
                
                Spacer()
                
                Button(action: {
                    viewModel.resetPassword { success in
                        if success {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }, label: {
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
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 10)
                })
                
            }
            .ignoresSafeArea()
            .padding(.horizontal)
            .padding(.top)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: CustomBackButton())
            PopupView(show: $viewModel.showPopUp)
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView(viewModel: ResetPasswordVM())
    }
}
