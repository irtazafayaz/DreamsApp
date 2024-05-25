//
//  ContentView.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 23/02/2024.
//

import SwiftUI

struct ContentView: View {
    
    //    @ObservedObject var sessionManager = SessionManager()
    
    var body: some View {
        
        if SessionManager.shared.isSignedIn {
            HomeView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
