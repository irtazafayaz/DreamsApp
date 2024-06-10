//
//  ChatHistoryCard.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 05/09/2023.
//

import SwiftUI

struct ChatHistoryCard: View {
    
    let message: String
    let date: String
    @State private var offset = CGSize.zero
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(message)
                    .font(Font.custom(FontFamily.semiBold.rawValue, size: 18))
                    .foregroundColor(Color(hex: Colors.labelDark.rawValue))
                    .lineLimit(1)
                Text(date)
                    .font(Font.custom(FontFamily.regular.rawValue, size: 10))
                    .foregroundColor(Color(hex: Colors.labelGray.rawValue))
                    .padding(.top, 2)
            }
            Spacer()
            Image("ic_arrow_right")
        }
        .padding()
        .background(RoundedCorners(
            tl: 10,
            tr: 10,
            bl: 10,
            br: 10
        ).fill(Color(hex: Colors.chatBG.rawValue)))
        .offset(x: offset.width, y: 0)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    let horizontalTranslation = gesture.translation.width
                    // Check if the card has been moved significantly to the left
                    if offset.width <= 0 || horizontalTranslation < 0 {
                        offset = CGSize(width: horizontalTranslation, height: 0)
                    }
                }
                .onEnded { _ in
                    if abs(offset.width) > 50 {
                        // remove the card
                    } else {
                        offset = .zero
                    }
                }
        )
    }
}

struct ChatHistoryCard_Previews: PreviewProvider {
    static var previews: some View {
        ChatHistoryCard(message: "Hello", date: "jj")
    }
}
