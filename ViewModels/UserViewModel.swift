//
//  UserViewModel.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 10/08/2023.
//

import Foundation
import RevenueCat

class UserViewModel: ObservableObject {
    
    @Published var isSubscriptionActive = false

    init() {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            self.isSubscriptionActive = customerInfo?.entitlements.all["Pro"]?.isActive == true
        }
    }
    
    
    func checkIfSubscribed(completion: @escaping (Bool) -> Void) {
        completion(true)
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if customerInfo?.entitlements.all["Pro"]?.isActive == true {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    
}
