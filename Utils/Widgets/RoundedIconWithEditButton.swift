//
//  RoundedIconWithEditButton.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 26/05/2023.
//

import SwiftUI

struct RoundedIconWithEditButton: View {
    
    let imageName: String
    
    var body: some View {
        ZStack(alignment: .bottomTrailing){
            Image(imageName)
                .resizable()
                .frame(width:100, height: 100)
                .clipShape(Circle())
            Image("ic_edit_button")
                .foregroundColor(.white)
                .frame(width: 25, height: 25)
                .background(Color.white)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
        }
    }
}
