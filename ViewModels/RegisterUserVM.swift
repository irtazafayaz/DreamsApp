//
//  RegisterUserVM.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 01/06/2023.
//

import Foundation

class RegisterUserVM: ObservableObject {
    
    //MARK: RegisterView
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isPasswordVisible = false
    @Published var isConfirmPasswordVisible = false
    @Published var isAgreed = false
    @Published var registerActionSuccess = false
    
    //MARK: CompleteYourProfileView
    @Published var isLoading = false
    @Published var fullName: String = ""
    @Published var phoneNumber: String = ""
    @Published var selectedGender = ""
    @Published var selectedDate = Date()
    @Published var showPopUp: Bool = false

    @Published var showAlert: Bool = false
    @Published var alertTitle: String = "Error"
    @Published var alertMsg: String = ""
    @Published var isCompleteProfileOpen: Bool = false

    let genders = ["Male", "Female", "Other"]
    
    private let service = BaseService.shared
    
    func createParams() -> [String: String] {
        var params = [String: String]()
        params["confirm_password"] = confirmPassword
        params["email"] = email
        params["password"] = password
        params["phone_number"] = phoneNumber
        params["full_name"] = fullName
//        params["gender"] = selectedGender
        return params
    }
    
    func registerUser() {
        if fullName.isEmpty {
            alertMsg = "Name cannot be empty"
            showAlert.toggle()
        } else if phoneNumber.isEmpty {
            alertMsg = "Phone Number cannot be empty"
            showAlert.toggle()
        } else if !isAgreed {
            alertMsg = "Kindly agree the terms & conditions."
            showAlert.toggle()
        } else {
            showPopUp.toggle()
            service.registerUser(from: .register, params: createParams()) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    print("API RESPONSE \(response)")
                    showPopUp.toggle()
                    self.registerActionSuccess = true
                case .failure(let error):
                    print("API ERROR \(error)")
                    showPopUp.toggle()
                    alertMsg = "\(error)"
                    showAlert.toggle()
                }
            }
        }
    }
    
    func moveToCompleteProfile() {
        if !Utilities.isValidEmail(email) {
            alertMsg = "Invalid Email"
            showAlert.toggle()
        } else if password.count < 8 {
            alertMsg = "Password should be 8 characters long"
            showAlert.toggle()
        } else if confirmPassword != password {
            alertMsg = "Password should be equal to confirm password"
            showAlert.toggle()
        } else {
            isCompleteProfileOpen.toggle()
        }
    }
    
}
