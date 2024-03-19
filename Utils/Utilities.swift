//
//  Utilities.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 05/09/2023.
//

import Foundation
import RevenueCat
import SwiftUI
import HorizonCalendar

class Utilities {
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        return dateFormatter
    }()
    
    static let jsonDecoder: JSONDecoder = {
       let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .useDefaultKeys
        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        return jsonDecoder
    }()
    
    static func formatDateAndTime(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    static func convertDayToDate(_ day: DayComponents) -> Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = day.month.year
        dateComponents.month = day.month.month
        dateComponents.day = day.day
        guard let date = calendar.date(from: dateComponents) else { return nil }
        return date
    }
    
    static func convertToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        guard let date = dateFormatter.date(from: dateString) else {
            return nil
        }
        return date
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

