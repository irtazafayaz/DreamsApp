//
//  PopupView.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 11/09/2023.
//

import SwiftUI

struct PopupView: View {
    
    @Binding var show: Bool
    
    var body: some View {
        ZStack {
            if show {
                Color.black.opacity(show ? 0.3 : 0).edgesIgnoringSafeArea(.all)
                VStack(alignment: .center, spacing: 0) {
                    LoadingView()
                }
                .padding()
                .frame(maxWidth: 200, maxHeight: 200)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}
