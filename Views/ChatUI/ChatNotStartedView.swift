//
//  ChatNotStartedView.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 27/02/2024.
//

import SwiftUI

struct ChatNotStartedView: View {
    
    @ObservedObject var viewModel: ChatVM
    
    var body: some View {
        VStack {
            Image("ic_app_logo_gray")
                .padding(.top, 50)
                .foregroundColor(Color(hex: Colors.primary.rawValue))
            Text("Capabilities")
                .font(Font.custom(FontFamily.bold.rawValue, size: 24))
                .foregroundColor(Color(hex: "BDBDBD"))
                .multilineTextAlignment(.center)
                .padding(.top, 10)
            VStack {
                Text("Answer all your questions.\n(Just ask me anything you like!)")
                    .font(Font.custom(FontFamily.medium.rawValue, size: 16))
                    .foregroundColor(Color(hex: "9E9E9E"))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedCorners(
                        tl: 10,
                        tr: 10,
                        bl: 10,
                        br: 10
                    ).fill(Color(hex: Colors.chatBG.rawValue)))
                Text("Generate all the text you want.\n(essays, articles, reports, stories, & more)")
                    .font(Font.custom(FontFamily.medium.rawValue, size: 16))
                    .foregroundColor(Color(hex: "9E9E9E"))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedCorners(
                        tl: 10,
                        tr: 10,
                        bl: 10,
                        br: 10
                    ).fill(Color(hex: Colors.chatBG.rawValue)))
                Text("Conversational AI.")
                    .font(Font.custom(FontFamily.medium.rawValue, size: 16))
                    .foregroundColor(Color(hex: "9E9E9E"))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedCorners(
                        tl: 10,
                        tr: 10,
                        bl: 10,
                        br: 10
                    ).fill(Color(hex: Colors.chatBG.rawValue)))
            }
            .padding()
            Text("These are just a few examples of what I can do.")
                .font(Font.custom(FontFamily.medium.rawValue, size: 16))
                .foregroundColor(Color(hex: "9E9E9E"))
            Spacer()
            Divider()
            BottomView(viewModel: viewModel)
        }
    }
}

#Preview {
    ChatNotStartedView(viewModel: ChatVM(with: ""))
}
