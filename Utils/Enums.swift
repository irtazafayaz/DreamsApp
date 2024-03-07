//
//  EnumUtils.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 02/06/2023.
//

import Foundation

enum Colors: String {
    case primary    = "#c266a7"
    case secondary  = "#E8FAF4"
    case divider    = "#EEEEEE"
    case labelDark  = "#212121"
    case labelLight = "#9E9E9E"
    case labelGray  = "#616161"
    case chatBG     = "#F5F5F5"
}

enum FontFamily: String {
    case bold        = "Urbanist-Bold"
    case semiBold    = "Urbanist-SemiBold"
    case regular     = "Urbanist-Regular"
    case medium     = "Urbanist-Medium"
}

enum DummyData: String {
    case dummyText = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s."
}

enum TextFieldType {
    case secure
    case normal
}

enum AppImages: String {
    case logo = "ic_app_logo"
    case loginIntro = "ic_loginintro"
}

enum Constants: String {
    case appName = "AI Dream Interpreter"
    case apiKey = "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"
    static let privacyURL = "https://www.termsfeed.com/live/4d1413e3-f4df-4b88-8350-052b4c5e308c"
    static let termsURL = "https://www.termsfeed.com/live/5dacdbaa-f525-4afc-b475-e598246063a2"
    static let revenueCat = "appl_xFsXdUptFTkRcJLQslEieltBKEe"
}

public enum URLs {
    static let baseURL: String = "http://154.62.109.121/"
}
