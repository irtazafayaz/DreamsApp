//
//  BottomView.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 27/02/2024.
//

import SwiftUI

struct BottomView: View {
    
    @ObservedObject var viewModel: ChatVM
    @State var generatingImageTapped: Bool = false
    
    var body: some View {
        VStack {
            Button {
                if let lastAssistantMessage = viewModel.msgsArr.last(where: { $0.role == .assistant })?.content {
                    if !lastAssistantMessage.trimmingCharacters(in: .whitespaces).isEmpty {
                        Task {
                            generatingImageTapped.toggle()
                            let result = await viewModel.generateImage(prompt: lastAssistantMessage)
                            generatingImageTapped.toggle()
                            if result == nil {
                                print("Failed to get image")
                            } else {
                                viewModel.dreamInterpretedImage = result
                            }
                        }
                    }
                }
            } label: {
                if generatingImageTapped {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: Colors.primary.rawValue)))
                        .scaleEffect(1.5)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 100)
                            .foregroundColor(Color(hex: Colors.primary.rawValue))
                            .shadow(color: Color.green.opacity(0.25), radius: 24, x: 4, y: 8)
                            .frame(height: 65)
                            .padding()
                        
                        Text("Generate Image")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .bold))
                    }
                }
            }
            
            HStack(alignment: .top, spacing: 8) {
                TextField("Ask me anything...", text: $viewModel.currentInput)
                .foregroundColor(.black)
                .padding()
                .frame(minHeight: CGFloat(30))
                .cornerRadius(8)
                .onChange(of: viewModel.currentInput) { newValue in
                    if newValue.isEmpty {
                        viewModel.currentInput = ""
                    }
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
                
                Button {
                    Task { @MainActor in
                        if UserDefaults.standard.isProMemeber {
                            viewModel.sendMessage()
                        } else {
                            SessionManager.shared.getMaxTries() { max in
                                if max > 0 {
                                    viewModel.sendMessage()
                                } else {
                                    viewModel.isPaywallPresented.toggle()
                                }
                            }
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
}

