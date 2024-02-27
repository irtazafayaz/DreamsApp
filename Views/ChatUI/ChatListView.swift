//
//  ChatListView.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 27/02/2024.
//

import SwiftUI

struct ChatListView: View {
    
    @ObservedObject var viewModel: ChatVM
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.msgsArr.filter({$0.role != .system}), id: \.id) { message in
                            MessageView(message: message)
                        }
                    }
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
                }
                Divider()
                BottomView(image: "profile", proxy: proxy, viewModel: viewModel)
                Spacer()
            }
            .onChange(of: viewModel.msgsArr.filter({$0.role != .system}).last?.content) { _ in
                viewModel.scrollToBottom(proxy: proxy)
            }
        }
    }
}

#Preview {
    ChatListView(viewModel: ChatVM(with: ""))
}
