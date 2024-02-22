//
//  DividerWithLabel.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 26/05/2023.
//

import Foundation
import SwiftUI

struct DividerWithLabel: View {
    
    let label: String
    let padding: CGFloat
    let dividerColor: Color
    let labelColor: Color
    let fontName: String
    let fontSize: CGFloat
    
    
    init(
        label: String,
        padding: CGFloat = 0,
        dividerColor: Color = Color(hex: Colors.divider.rawValue),
        labelColor: Color = Color(hex: "#616161"),
        fontName: String = FontFamily.medium.rawValue,
        fontSize: CGFloat = 18
    ) {
        self.label = label
        self.padding = padding
        self.dividerColor = dividerColor
        self.labelColor = labelColor
        self.fontName = fontName
        self.fontSize = fontSize
    }
    
    var body: some View {
        HStack {
            Text(label).foregroundColor(labelColor)
                .font(Font.custom(fontName, size: fontSize))
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: true, vertical: false)
            dividerLine
        }
    }
    private var dividerLine: some View {
        return VStack { Divider().background(dividerColor) }.padding(padding)
    }
}
