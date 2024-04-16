//
//  DreamInterpreterView.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 25/03/2024.
//

import Foundation
import SwiftUI
import OpenAIKit

final class ViewModel: ObservableObject {
    
    private var openAI: OpenAI?
    
    func setup() {
        openAI = OpenAI(Configuration(organizationId: "Personal", apiKey: EnvironmentInfo.apiKey))
    }
    
    func generateImage(prompt: String) async -> UIImage? {
        guard let openai = openAI else { return nil }
        do {
            let params = ImageParameters(prompt: prompt, resolution: .medium, responseFormat: .base64Json)
            let result = try await openai.createImage(parameters: params)
            let data = result.data[0].image
            let image = try openai.decodeBase64Image(data)
            return image
        } catch {
            print(String(describing: error))
            return nil
        }
    }
    
}

struct DreamInterpreterView: View {
    
    @ObservedObject private var viewModel = ViewModel()
    @State var text = ""
    @State var image: UIImage?
    
    var body: some View {
        NavigationView {
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                } else {
                    Text("Type prompt to generate image")
                }
                
                Spacer()
                
                TextField("Type here...", text: $text)
                    .padding()
                
                
                Button ("Generate") {
                    if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                        Task {
                            let result = await viewModel.generateImage(prompt: text)
                            if result == nil {
                                print("Failed to get image")
                            } else {
                                image = result
                            }
                        }
                    }
                }
                
                
                
                
                
                
                
                
                
            }
            .onAppear{
                viewModel.setup()
            }
        }
    }
    
    
}
