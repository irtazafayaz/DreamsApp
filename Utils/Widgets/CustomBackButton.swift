//
//  CustomBackButton.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 26/05/2023.
//

import Foundation
import SwiftUI

struct CustomBackButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image("ic_back_arrow")
                .foregroundColor(.black)
        }
    }
}
