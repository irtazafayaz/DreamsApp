//
//  ProfileVM.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 08/09/2023.
//

import Foundation

class ProfileVM: ObservableObject {
    
    private let service = BaseService.shared
    @Published var logoutActionSuccess: Bool = false
    @Published var showPopUp: Bool = false
    @Published var goToLogin: Bool = false

    func logout(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = UserDefaults.standard.refreshToken else { return }
        showPopUp.toggle()
        service.logout(from: .logout, refreshToken: refreshToken) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                print("API RESPONSE \(response)")
                showPopUp.toggle()
                UserDefaults.standard.refreshToken = ""
                UserDefaults.standard.accessToken = ""
                UserDefaults.standard.loggedInEmail = ""
                UserDefaults.standard.rememberMe = false
                self.logoutActionSuccess = true
                completion(true)
            case .failure(let error):
                print("API ERROR \(error)")
                showPopUp.toggle()
                completion(false)
            }
        }
    }
    
    

}
