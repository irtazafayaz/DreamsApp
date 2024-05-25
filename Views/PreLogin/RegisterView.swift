//
//  RegisterView.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 26/05/2024.
//

import SwiftUI

struct RegisterView: View {
    
    @ObservedObject private var viewModel = LoginVM()
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var openLoginView = false
    
    var body: some View {
        ZStack {
            VStack {
                
                Image("ic_app_logo_gray")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color(hex: Colors.primary.rawValue))
                    .padding(.top, 50)
                
                Text("Register")
                    .font(Font.custom(FontFamily.bold.rawValue, size: 40))
                    .foregroundColor(Color(hex: Colors.primary.rawValue))
                    .padding(.top, 20)
                
                
                
                CustomTextField(label: $email, textfieldType: .email, placeholder: "Email")
                    .padding(.top, 40)
                CustomTextField(label: $password, textfieldType: .password, placeholder: "Password")
                CustomTextField(label: $confirmPassword, textfieldType: .password, placeholder: "Confirm Password")
                
                
                Button {
                    SessionManager.shared.register(email: email, password: password)
                } label: {
                    Text("Register")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color(hex: Colors.primary.rawValue))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                .padding(.top, 20)
                
                Spacer()
                
                HStack {
                    Text("Don't have an account?")
                        .font(Font.system(size: 16))
                        .foregroundColor(.black)
                    Button(action: { openLoginView.toggle() }) {
                        Text("Register")
                            .font(Font.system(size: 16))
                            .bold()
                            .underline()
                            .foregroundColor(.black)
                    }
                }
                .foregroundColor(.white)
                .padding(.bottom)
                
            }
            .navigationDestination(isPresented: $viewModel.isLoginSuccessful, destination: {
                HomeView()
            })
            .navigationDestination(isPresented: $openLoginView, destination: {
                LoginView()
            })
            
        }
    }
}

#Preview {
    RegisterView()
}
