//
//  LoginViewModel.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 30/05/2023.
//

import Foundation
import SwiftUI

class LoginVM: ObservableObject {
    
    @Published var email: String = "thefreelancers.devs@gmail.com"
    @Published var password: String = "12345678"
    @Published var isPasswordVisible = false
    @Published var isAgreed = false
    @Published var loginActionSuccess: Bool = false
    @Published var showPopUp: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = "Error"
    @Published var alertMsg: String = ""
    
    private let service = BaseService.shared
    
    func createParams() -> [String: String] {
        var params = [String: String]()
        params["email"] = email
        params["password"] = password
        return params
    }
    
    func login() {
        if !Utilities.isValidEmail(email) || password.count < 8 {
            alertMsg = "Invalid Email"
            showAlert.toggle()
        } else if password.count < 8 {
            alertMsg = "Password should be 8 characters long"
            showAlert.toggle()
        } else {
            showPopUp.toggle()
            service.login(from: .login, params: createParams()) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    showPopUp.toggle()
                    UserDefaults.standard.refreshToken = response.refreshToken
                    UserDefaults.standard.accessToken = response.accessToken
                    UserDefaults.standard.rememberMe = isAgreed
                    self.loginActionSuccess = true
                case .failure(let error):
                    print("API ERROR \(error)")
                    showPopUp.toggle()
                    alertMsg = "\(error)"
                    showAlert.toggle()
                }
            }
        }
    }
    
    
    
}

