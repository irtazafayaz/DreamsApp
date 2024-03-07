//
//  BottomView.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 27/02/2024.
//

import SwiftUI

struct BottomView: View {
    
    var image: String
    var proxy: ScrollViewProxy?
    @ObservedObject var viewModel: ChatVM
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            TextField("Ask me anything...", text: $viewModel.currentInput)
            .foregroundColor(.black)
            .padding()
            .frame(minHeight: CGFloat(30))
            .background(Color(hex: "#1417CE92"))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hex: Colors.primary.rawValue), lineWidth: 2)
            )
            .onChange(of: viewModel.currentInput) { newValue in
                if newValue.isEmpty {
                    viewModel.currentInput = ""
                }
            }
            .focused($isTextFieldFocused)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            
            Button {
                Task { @MainActor in
                    isTextFieldFocused = false
                    if proxy != nil {
                        viewModel.scrollToBottom(proxy: proxy!)
                    }
                    if !UserDefaults.standard.isProMemeber {
                        viewModel.sendMessage()
                    } else {
                        viewModel.isPaywallPresented.toggle()
                    }
                }
            } label: {
                Circle()
                    .fill(Color(hex: Colors.primary.rawValue))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image("ic_send_btn_icon")
                            .resizable()
                            .scaledToFit()
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding()
                    )
            }
            .disabled(viewModel.currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.top, 12)
    }
}


#Preview {
    BottomView(image: "", viewModel: ChatVM(with: ""))
}
