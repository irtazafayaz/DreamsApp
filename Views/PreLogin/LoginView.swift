//
//  LoginView.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 09/03/2024.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    
    @ObservedObject private var viewModel = LoginVM()
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        
        VStack {

            Image("ic_app_logo_gray")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(Color(hex: Colors.primary.rawValue))
                .padding(.top, 50)
            
            Text("Login")
                .font(Font.custom(FontFamily.bold.rawValue, size: 40))
                .foregroundColor(Color(hex: Colors.primary.rawValue))
                .padding(.top, 20)
            

            
            CustomTextField(label: $email, textfieldType: .email, placeholder: "Email")
                .padding(.top, 40)
            CustomTextField(label: $email, textfieldType: .password, placeholder: "Password")

            
            Button {
                
            } label: {
                Text("Login")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(hex: Colors.primary.rawValue))
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            .padding(.top, 20)
            
            Spacer()

        }
        .navigationDestination(isPresented: $viewModel.isLoginSuccessful, destination: {
            HomeView()
        })
        
        
        
    }
}

#Preview {
    LoginView()
}
