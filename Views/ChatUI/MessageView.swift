//
//  MessageView.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 27/02/2024.
//

import SwiftUI

struct MessageView: View {
    
    var message: Message
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            HStack {
                Text(message.content)
                    .font(.custom(FontFamily.medium.rawValue, size: 18))
                    .foregroundColor(message.role == .user ? .white : .black)
                    .padding()
                    .background(RoundedCorners(
                        tl: message.role == .user ? 20 : 8,
                        tr: 20,
                        bl: 20,
                        br: message.role == .user ? 8 : 20
                    ).fill(message.role == .user ? Color(hex: Colors.primary.rawValue) : Color(hex: "#F5F5F5")))
            }
            if message.role == .assistant || message.role == .paywall {
                Spacer()
            }
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    MessageView(message: Message(id: "", content: "", createdAt: .now, role: .assistant))
}
