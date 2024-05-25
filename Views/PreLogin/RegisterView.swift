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

    var body: some View {
        
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

        }
        .navigationDestination(isPresented: $viewModel.isLoginSuccessful, destination: {
            HomeView()
        })
        
        
        
    }
}

#Preview {
    RegisterView()
}
