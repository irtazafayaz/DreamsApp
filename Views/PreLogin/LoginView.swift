//
//  LoginView.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 09/03/2024.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var openRegisterView = false
    @State private var errorMessage: String?
    @State private var showAlert = false

    var body: some View {
        VStack {
            
            Image("ic_app_logo_gray")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(Color(hex: Colors.primary.rawValue))
                .padding(.top, 50)
            
            Text(openRegisterView ? "Register" : "Login")
                .font(Font.custom(FontFamily.bold.rawValue, size: 40))
                .foregroundColor(Color(hex: Colors.primary.rawValue))
                .padding(.top, 20)
            
            CustomTextField(label: $email, textfieldType: .email, placeholder: "Email")
                .padding(.top, 40)
            CustomTextField(label: $password, textfieldType: .password, placeholder: "Password")
            if openRegisterView {
                CustomTextField(label: $confirmPassword, textfieldType: .password, placeholder: "Confirm Password")
            }
            
            Button {
                if openRegisterView {
                        SessionManager.shared.register(email: email, password: password) { result in
                            switch result {
                            case .success():
                                errorMessage = nil
                                // Navigate to the next screen or show success
                            case .failure(let error):
                                errorMessage = error.localizedDescription
                                showAlert = true
                            }
                        }
                    } else {
                        SessionManager.shared.login(email: email, password: password) { result in
                            switch result {
                            case .success():
                                errorMessage = nil
                                // Navigate to the next screen or show success
                            case .failure(let error):
                                errorMessage = error.localizedDescription
                                showAlert = true
                            }
                        }
                    }
                
            } label: {
                Text(openRegisterView ? "Register" : "Login")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(hex: Colors.primary.rawValue))
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            .padding(.top, 20)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? "An error occurred"), dismissButton: .default(Text("OK")))
            }
            
            Spacer()
            
            HStack {
                Text(openRegisterView ? "Already have an account?" : "Don't have an account?")
                    .font(Font.system(size: 16))
                    .foregroundColor(.black)
                Button(action: { openRegisterView.toggle() }) {
                    Text(openRegisterView ? "Login" : "Register")
                        .font(Font.system(size: 16))
                        .bold()
                        .underline()
                        .foregroundColor(.black)
                }
            }
            .foregroundColor(.white)
            .padding(.bottom)
            
            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
                .font(.footnote)
                .foregroundColor(.black)
            
        }
        
    }
}

#Preview {
    LoginView()
}
