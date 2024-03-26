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
    
    var body: some View {
        
        VStack {

            Image("ic_app_logo_gray")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .foregroundColor(Color(hex: Colors.primary.rawValue))
                .padding(.top, 30)
            
            Text("Login")
                .font(Font.custom(FontFamily.bold.rawValue, size: 40))
                .foregroundColor(Color(hex: Colors.primary.rawValue))
                .padding(.top, 20)
            
            SignInWithAppleButton { request in
                viewModel.handleSignWithAppleRequest(request)
            } onCompletion: { result in
                viewModel.handleSignWithAppleCompletion(result)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .padding()
            .cornerRadius(10)
            .padding(.top, 40)
        }
        .navigationDestination(isPresented: $viewModel.isLoginSuccessful, destination: {
            HomeView()
        })
        
        
        
    }
}

#Preview {
    LoginView()
}
