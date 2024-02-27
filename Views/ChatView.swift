//
//  ChatView.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 06/06/2023.
//

import SwiftUI
import PDFKit
import UIKit

struct ChatView: View {
    
    //MARK: - Data Members -
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var userViewModel: UserViewModel
    @StateObject private var viewModel: ChatVM = ChatVM(with: "")
    
    //MARK: - Initialization Methods -
    
    init(messagesArr: [Message] = []) {
        _viewModel = StateObject(wrappedValue: ChatVM(with: "", messages: messagesArr))
    }
    
    var body: some View {
        VStack {
            if !viewModel.msgsArr.isEmpty {
                ChatListView(viewModel: viewModel)
            } else {
                ChatNotStartedView(viewModel: viewModel)
            }
        }
        .padding(.horizontal, 10)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Chat")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading, content: {
                CustomBackButton()
            })
        }
        .navigationDestination(isPresented: $viewModel.isPaywallPresented) {
            PaywallView(isPaywallPresented: $viewModel.isPaywallPresented)
        }
    }
    
}






