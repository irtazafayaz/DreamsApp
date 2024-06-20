//
//  ChatHistoryPreview.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 27/03/2024.
//

import SwiftUI

struct ChatHistoryPreview: View {
    
    private var dream: FirebaseDreams?
    @State private var textHeight: CGFloat = 0
    
    init(dream: FirebaseDreams?) {
        self.dream = dream
    }
    
    var body: some View {
        ScrollView {
            
            VStack(spacing: 0) {
                
                if let interpretedDream = dream?.message {
                    
                    Text("Interpreted Dream:")
                        .bold()
                        .font(.title2)
                    
                    Text(interpretedDream.interpretedText)
                        .padding()
                        .background(Color(hex: Colors.primary.rawValue).opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.vertical)
                    
                    if let url = URL(string: interpretedDream.image) {
                        AsyncImage(url: url, content: view)
                            .padding(.vertical, 10)
                    } else {
                        Color.black
                            .frame(height: 200)
                    }
                    
                    if let tags = interpretedDream.tags {
                        HStack {
                            Text("Tags:")
                                .font(.title3)
                                .bold()
                                .frame(alignment: .leading)
                            Text("\(tags.joined(separator: ", "))")
                                .font(.title3)

                        }
                        .padding(.top)
                    }
                    
                    if let inputText = interpretedDream.inputText {
                        Text(inputText)
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(.vertical)
                        
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
                .frame(maxWidth: .infinity)
                .frame(height: 400)
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

#Preview {
    ChatHistoryPreview(
        dream: FirebaseDreams(
        date: Date().description,
        message: DreamContent(
            image: "",
            interpretedText: "Hello kdnsadbkas dskd asjk dakjd askjd jkas djas jdajdas dkja skjdasjkd jasd jk asdjaskjd jas djkas djka djas jkd asj dkjad jkas djkasjd dkansjdnkaskdjksadlk",
            tags: ["books", "movies"],
            inputText: "dsjkdhajskdhjksad daskhdj dhasjkhdjkas hd jashdjk asd djahjsk dks jdhasjk dasd asdhjkashd jkashdj"
        ),
        user: "email"
        )
    )
}
