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
            SignInWithAppleButton { request in
                viewModel.handleSignWithAppleRequest(request)
            } onCompletion: { result in
                viewModel.handleSignWithAppleCompletion(result)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .padding()
            .cornerRadius(10)
        }
        .navigationDestination(isPresented: $viewModel.isLoginSuccessful, destination: {
            HomeView()
        })
        
        
        
    }
}

#Preview {
    LoginView()
}
