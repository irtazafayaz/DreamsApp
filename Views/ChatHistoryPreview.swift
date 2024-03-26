//
//  ChatHistoryPreview.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 27/03/2024.
//

import SwiftUI

struct ChatHistoryPreview: View {
    
    private var dream: FirebaseMessages?
    
    init(dream: FirebaseMessages?) {
        self.dream = dream
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            if let interpretedDream = dream?.message {
                
                ScrollView {
                    Text(interpretedDream.interpretedText)
                        .padding()
                        .background(Color(hex: Colors.primary.rawValue).opacity(0.5))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: Colors.primary.rawValue), lineWidth: 2)
                )
                
                if let url = URL(string: interpretedDream.image) {
                    AsyncImage(url: url, content: view)
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                } else {
                    Color.black
                        .frame(height: 200)
                }
                
                Spacer()
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Preview")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading, content: {
                CustomBackButton()
            })
        }
    }
    
    @ViewBuilder
    private func view(for phase: AsyncImagePhase) -> some View {
        switch phase {
        case .empty:
            ProgressView()
        case .success(let image):
            image
                .resizable()
        case .failure(let error):
            VStack(spacing: 16) {
                Image(systemName: "xmark.octagon.fill")
                    .foregroundColor(.red)
                Text(error.localizedDescription)
                    .multilineTextAlignment(.center)
            }
        @unknown default:
            Text("Unknown")
                .foregroundColor(.gray)
        }
    }
    
}
