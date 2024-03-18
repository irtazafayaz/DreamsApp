//
//  ContentView.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 23/02/2024.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var sessionManager = SessionManager()
    
//    init() {
//        sessionManager.getCurrentAuthUser()
//    }
    
    var body: some View {
        
        switch sessionManager.authState {
        case .login:
            LoginView()
                .environmentObject(sessionManager)
        case .home(_):
            HomeView()
                .environmentObject(sessionManager)
        }
    }
}

#Preview {
    ContentView()
}
