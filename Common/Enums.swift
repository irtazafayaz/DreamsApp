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

enum AppImages: String {
    case logo = "ic_app_logo_gray"
    case loginIntro = "ic_loginintro"
}

enum Constants: String {
    case appName = "AI Dream Interpreter"
    static let privacyURL = "https://www.termsfeed.com/live/3603a8e2-5213-4586-9943-c13229cfdfc2"
    static let termsURL = "https://www.termsfeed.com/live/718eded9-5dae-4f6f-8fc3-9287240cde8a"
}

public enum URLs {
    static let baseURL: String = "http://154.62.109.121/"
}

public enum EnvironmentInfo {
    enum Keys {
        static let apiKey = "API_KEY"
        static let revenueCat = "REVENUE_CAT"
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist not found")
        }
        return dict
    }()
    
    static let apiKey: String = {
        guard let apiKeyString = EnvironmentInfo.infoDictionary[Keys.apiKey] as? String else {
            fatalError("API KEY not found")
        }
        return apiKeyString
    }()
    
    static let revenueCat: String = {
        guard let apiKeyString = EnvironmentInfo.infoDictionary[Keys.revenueCat] as? String else {
            fatalError("REVENUE KEY not found")
        }
        return apiKeyString
    }()
    
}
