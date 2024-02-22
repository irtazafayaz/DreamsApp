//
//  RegisterPasswordVM.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 30/05/2023.
//

import Foundation
import SwiftUI

class ResetPasswordVM: ObservableObject {
    
    @Published var email: String = ""
    @Published var passwordResetActionSuccess: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = "Error"
    @Published var alertMsg: String = ""
    @Published var showPopUp: Bool = false
    
    private let service = BaseService.shared
    
    func resetPassword(completion: @escaping (Bool) -> Void) {
        if !Utilities.isValidEmail(email) || email.isEmpty {
            alertMsg = "Invalid Email"
            showAlert.toggle()
        } else {
            showPopUp.toggle()
            service.forgotPassword(from: .forgotPassword, params: ["email": email.lowercased()]) { [weak self] response in
                guard let self = self else { return }
                switch response {
                case .success(_):
                    self.passwordResetActionSuccess = true
                    showPopUp.toggle()
                    completion(true)
                case .failure(let error):
                    print("> API ERROR:\(error)")
                    showPopUp.toggle()
                    showAlert.toggle()
                    completion(false)
                }
            }
            
        }
    }
}
