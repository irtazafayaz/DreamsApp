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
    
    @StateObject private var viewModel: ChatVM = ChatVM(with: "")
    
    //MARK: - Initialization Methods -
    
    init(messagesArr: [Message] = [], selectedDate: Date = .now) {
        _viewModel = StateObject(wrappedValue: ChatVM(with: "", messages: messagesArr, selectedDate: selectedDate))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            if let lastAssistantMessage = viewModel.msgsArr.last(where: { $0.role == .assistant }) {
                
                ScrollView {
                    Text(lastAssistantMessage.content)
                        .padding()
                        .background(Color(hex: Colors.primary.rawValue).opacity(0.5))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: Colors.primary.rawValue), lineWidth: 2)
                )

            }
            
            if let image = viewModel.dreamInterpretedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .padding()
            }
            
            Spacer()
            Divider()
            BottomView(viewModel: viewModel)
            
        }
        .onAppear{
            viewModel.setup()
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






