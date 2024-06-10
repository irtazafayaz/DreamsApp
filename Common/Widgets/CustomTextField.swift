//
//  CustomTextField.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 26/05/2024.
//

import Foundation
import SwiftUI

enum TextFieldType {
    case email
    case normal
    case password
}

struct CustomTextField: View {
    
    @Binding var label: String
    @State private var isVisible: Bool = false
    
    var textfieldType: TextFieldType
    var placeholder: String = "Enter here..."
    
    var body: some View {
        HStack {
            if textfieldType != .normal {
                Image(systemName: textfieldType == .email ? "envelope" : "lock")
                    .foregroundColor(.white)
            }
            if textfieldType == .email || textfieldType == .normal || isVisible {
                TextField("", text: $label, prompt: Text(placeholder).foregroundColor(.white))
                    .tint(.white)
                    .foregroundStyle(.white)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(12)
            } else {
                SecureField("", text: $label, prompt: Text(placeholder).foregroundColor(.white))
                    .tint(.white)
                    .foregroundStyle(.white)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(12)
            }
            if textfieldType == .password {
                Button(action: {
                    self.isVisible.toggle()
                }) {
                    Image(systemName: self.isVisible ? "eye.slash" : "eye")
                        .foregroundColor(.white)
                }
            }
            
        }
        .padding(.horizontal)
        .background(RoundedRectangle(cornerRadius: 10).fill(.black.opacity(0.7)))
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}

#Preview {
    CustomTextField(label: .constant("Enter"), textfieldType: .normal)
}
