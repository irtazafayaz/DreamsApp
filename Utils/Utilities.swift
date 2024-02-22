//
//  Utilities.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 05/09/2023.
//

import Foundation
import RevenueCat
import SwiftUI

class Utilities {
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy - hh:mm a"
        return dateFormatter
    }()
    
    static let jsonDecoder: JSONDecoder = {
       let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .useDefaultKeys
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()
    
    static func formatDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    static func updateSubscription() {
        Purchases.shared.getCustomerInfo { cust, error in
           _ = updateCustumerInCache(cust: cust)
        }
    }
    static func updateCustumerInCache(cust: CustomerInfo?) -> Bool {
        UserDefaults.standard.isProMemeber = cust?.entitlements["Pro"]?.isActive == true
        UserDefaults.standard.subscriptionDate = cust?.entitlements["Pro"]?.latestPurchaseDate
        UserDefaults.standard.expiryDate = cust?.entitlements["Pro"]?.expirationDate
        UserDefaults.standard.subscriptionType = cust?.entitlements["Pro"]?.productIdentifier ?? ""
        return cust?.entitlements["Pro"]?.isActive == true
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
}

