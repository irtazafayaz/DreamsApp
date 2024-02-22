//
//  UnderlinedTextField.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 26/05/2023.
//

import Foundation
import SwiftUI


struct UnderlinedTextField: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 8)
            .overlay(
                RoundedRectangle(cornerRadius: 1)
                    .frame(height: 1)
                    .foregroundColor(Color(hex: Colors.primary.rawValue))
                    .padding(.top, 20)
            )
    }
}

extension View {
    func underlinedTextFieldStyle() -> some View {
        self.modifier(UnderlinedTextField())
    }
}
