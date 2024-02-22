//
//  CustomOTPBox.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 29/05/2023.
//

import SwiftUI

struct CustomOTPBox: View {

    var textboxColor = Color(red: 235/255, green: 235/255, blue: 235/255)
    var selectedColor = Color (red: 122/255, green: 177/255, blue: 253/255)
    var code: String
    var isSelected: Bool = false


    var body: some View {
        Text(code)
            .foregroundColor(.black)
            .frame(width: 83.5, height: 70)
            .background(textboxColor)
            .cornerRadius(10)
            .overlay(content: {
                RoundedRectangle(cornerRadius: 10).stroke(isSelected ? selectedColor : Color.clear, lineWidth: 4)
            })
    }

}
