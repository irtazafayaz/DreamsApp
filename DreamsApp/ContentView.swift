//
//  ContentView.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 23/02/2024.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var sessionManager = SessionManager.shared
    
    var body: some View {
        ZStack {
            if sessionManager.isSignedIn {
                HomeView()
            } else {
                LoginView()
            }
            
            if sessionManager.isLoading {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                
                ProgressView()
                    .scaleEffect(2)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
    }
}

#Preview {
    ContentView()
}
