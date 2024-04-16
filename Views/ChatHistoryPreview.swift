//
//  ChatHistoryPreview.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 27/03/2024.
//

import SwiftUI

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


struct ChatHistoryPreview: View {
    
    private var dream: FirebaseMessages?
    @State private var textHeight: CGFloat = 0
    
    init(dream: FirebaseMessages?) {
        self.dream = dream
    }
    
    var body: some View {
        ScrollView {
            
            VStack(spacing: 0) {
                
                if let interpretedDream = dream?.message {
                    
                    Text(interpretedDream.interpretedText)
                        .padding()
                        .background(Color(hex: Colors.primary.rawValue).opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(hex: Colors.primary.rawValue), lineWidth: 2)
                        )
                        .padding()
                                        
                    if let url = URL(string: interpretedDream.image) {
                        AsyncImage(url: url, content: view)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .padding(.vertical, 10)
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
