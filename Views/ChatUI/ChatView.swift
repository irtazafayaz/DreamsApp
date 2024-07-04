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
                        .padding(.vertical)
                }
                
                if let image = viewModel.dreamInterpretedImage {
                    Image(uiImage: image)
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .frame(height: 400)

                    
                }
                
                if viewModel.isDreamSaved {
                    
                    if viewModel.tags.count > 0 {
                        HStack {
                            Text("Tags:")
                                .font(.title3)
                                .bold()
                                .frame(alignment: .leading)
                            Text("\(viewModel.tags.joined(separator: ", "))")
                                .font(.title3)
                            
                        }
                        .padding(.top)
                    }
                    
                    Text(viewModel.currentInput)
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.vertical)
                }
                
            }
            
            Divider()
            if !viewModel.isDreamSaved {
                bottomView
            }
            
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
            
            if viewModel.dreamInterpretedImage != nil {
                tagInputView
                    .padding(.top, 10)
                
                saveDreamButtonView
                
                
            } else {
                generateImageButton
                if viewModel.msgsArr.last(where: { $0.role == .assistant }) == nil {
                    sendMessageInputView

                }
            }
            
        }
    }
    
    var generateImageButton: some View {
        VStack {
            if let lastAssistantMessage = viewModel.msgsArr.last(where: { $0.role == .assistant })?.content,
               !lastAssistantMessage.trimmingCharacters(in: .whitespaces).isEmpty {
                
                Button {
                    Task {
                        generatingImageTapped.toggle()
                        let result = await viewModel.generateImage(prompt: lastAssistantMessage)
                        generatingImageTapped.toggle()
                        if result == nil {
                            print("Failed to get image")
                        } else {
                            DispatchQueue.main.async {
                                viewModel.dreamInterpretedImage = result
                            }
                        }
                    }
                    
                } label: {
                    if generatingImageTapped {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: Colors.primary.rawValue)))
                            .scaleEffect(1.5)
                    } else {
                        Text("Generate the Image of My Dream")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .bold))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color(hex: Colors.primary.rawValue))
                            .cornerRadius(10)
                    }
                }
                .padding(.top)
                
            }
        }
    }
    
    var sendMessageInputView: some View {
        HStack(alignment: .top, spacing: 8) {
            TextField("Describe your dream...", text: $viewModel.currentInput)
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
                                SessionManager.shared.removeFirstMessage()
                                viewModel.sendMessage()
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
    
    var saveDreamButtonView: some View {
        Button {
            Task {
                viewModel.storeMessageInFirebase()
                viewModel.decrementMaxTriesCount()
                viewModel.isDreamSaved = true
            }
            
        } label: {
            Text("Save Dream")
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(hex: Colors.primary.rawValue))
                .cornerRadius(10)
        }
        .padding(.top)
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
        Message(id: UUID().uuidString, content: "Hello fjdsfjhdsjfh dsjfhjsd fjsdhfjjhsjahfkajhdsjkjash jashd jashjkd hasjkhd kjas nbcsajcjashjdfhasjkdh  dhjkashdjkashd hsdk jahskjd", createdAt: .now, role: .assistant)
    ])
}


