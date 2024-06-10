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
    @State var generatingImageTapped: Bool = false
    @State private var tagInput: String = ""
    @State private var isExpanded: Bool = false
    
    //MARK: - Initialization Methods -
    
    init(messagesArr: [Message] = [], selectedDate: Date = .now) {
        _viewModel = StateObject(wrappedValue: ChatVM(with: "", messages: messagesArr, selectedDate: selectedDate))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                
                if let lastAssistantMessage = viewModel.msgsArr.last(where: { $0.role == .assistant }) {
                    Text(lastAssistantMessage.content)
                        .padding()
                        .background(Color(hex: Colors.primary.rawValue).opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: Colors.primary.rawValue), lineWidth: 2)
                        )
                        .padding()
                }
                
                if let image = viewModel.dreamInterpretedImage {
                    Image(uiImage: image)
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .frame(height: 400)
                }
                
            }
            
            Divider()
            bottomView
            
        }
        .disabled(viewModel.isLoading)
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
    
    var bottomView: some View {
        VStack(spacing: 8) {
            
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                Text(isExpanded ? "-" : "+")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color(hex: Colors.primary.rawValue))
                    .clipShape(Circle())
            }
            .padding(.top)
            
            if isExpanded {
                if let lastAssistantMessage = viewModel.msgsArr.last(where: { $0.role == .assistant })?.content, !lastAssistantMessage.trimmingCharacters(in: .whitespaces).isEmpty {
                    
                    HStack {
                        Button {
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
                            
                        } label: {
                            if generatingImageTapped {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: Colors.primary.rawValue)))
                                    .scaleEffect(1.5)
                            } else {
                                Text("Generate Image")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18, weight: .bold))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(.black)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.top)
                    }
                }
                
                tagInputView
                    .padding(.top, 10)
                
                HStack(alignment: .top, spacing: 8) {
                    TextField("Ask me anything...", text: $viewModel.currentInput)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.gray.opacity(0.2))
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
    
    var tagInputView: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Add a tag...", text: $tagInput, onCommit: {
                    addTag()
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    addTag()
                }) {
                    Text("Add")
                        .foregroundColor(Color(hex: Colors.primary.rawValue))
                        .bold()
                }
            }
            
            if !viewModel.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.tags, id: \.self) { tag in
                            HStack {
                                Text(tag)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(Capsule())
                                
                                Button(action: {
                                    removeTag(tag)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding(.trailing, 4)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
    
    func addTag() {
        let trimmedTag = tagInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !viewModel.tags.contains(trimmedTag) {
            viewModel.tags.append(trimmedTag)
        }
        tagInput = ""
    }
    
    func removeTag(_ tag: String) {
        viewModel.tags.removeAll { $0 == tag }
    }
}

#Preview {
    ChatView(messagesArr: [
        Message(id: UUID().uuidString, content: "Hello fjdsfjhdsjfh dsjfhjsd fjsdhfjjhsjahfkajhdsjk", createdAt: .now, role: .assistant)
    ])
}


