//
//  LoginView.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 25/05/2023.
//

import SwiftUI

struct LoginView: View {
    
    @ObservedObject private var viewModel: LoginVM
    @State private var isEmailValid: Bool = true
    
    init(viewModel: LoginVM) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                
                Text("Welcome back")
                    .font(Font.custom(FontFamily.bold.rawValue, size: 32))
                    .frame(alignment: .leading)
                
                Text("Please enter your email & password to log in.")
                    .font(Font.custom(FontFamily.regular.rawValue, size: 18))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 10)
                    .lineLimit(2)
                
                ScrollView {
                    
                    // MARK: Email Text Field
                    
                    VStack(alignment: .leading) {
                        Text("Email")
                            .font(.headline)
                        HStack {
                            TextField("Email", text: $viewModel.email)
                            Image("ic_dropdown")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color(hex: Colors.primary.rawValue))
                                .frame(width: 20, height: 20)
                        }
                        .padding(.bottom, 20)
                        .underlinedTextFieldStyle()
                    }
                    .padding(.top, 10)
                    
                    // MARK: Password Text Field
                    
                    VStack(alignment: .leading) {
                        Text("Password")
                            .font(.headline)
                        HStack {
                            if viewModel.isPasswordVisible {
                                TextField("Password", text: $viewModel.password)
                            } else {
                                SecureField("Password", text: $viewModel.password)
                            }
                            Button(action: {
                                viewModel.isPasswordVisible.toggle()
                            }) {
                                Image(systemName: viewModel.isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                    .foregroundColor(Color(hex: Colors.primary.rawValue))
                            }
                        }
                        .padding(.bottom, 20)
                        .underlinedTextFieldStyle()
                    }
                    .padding(.top, 10)
                    
                    // MARK: CheckBox Agreement
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Button(action: {
                                viewModel.isAgreed.toggle()
                            }) {
                                Image(viewModel.isAgreed ? "ic_checkbox_filled" : "ic_checkbox")
                                    .foregroundColor(viewModel.isAgreed ? .green : .gray)
                            }
                            Text("Remember me")
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                                .lineLimit(nil)
                                .frame(alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, 10)
                    
                    Divider()
                        .frame(height: 1)
                        .overlay(Color(hex: Colors.divider.rawValue))
                        .padding(.top, 20)
                    
                    NavigationLink(destination: ResetPasswordView(viewModel: ResetPasswordVM())) {
                        Text("Forgot password?")
                            .foregroundColor(Color(hex: Colors.primary.rawValue))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 10)
                            .font(Font.custom(FontFamily.bold.rawValue, size: 18))
                    }
                    
                    HStack(alignment: .center) {
                        Text("Don't have an account?")
                            .font(Font.custom(FontFamily.medium.rawValue, size: 16))
                        NavigationLink(destination: RegisterView(viewModel: RegisterUserVM())) {
                            Text("Signup")
                                .foregroundColor(Color(hex: Colors.primary.rawValue))
                                .font(Font.custom(FontFamily.bold.rawValue, size: 16))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
                    
                }
                
                Button(action: {
                    viewModel.login()
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 100)
                            .foregroundColor(Color(hex: Colors.primary.rawValue))
                            .shadow(color: Color.green.opacity(0.25), radius: 24, x: 4, y: 8)
                            .frame(height: 65)
                            .padding()
                        
                        Text("Login")
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .bold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 10)
                })
                
            }
            .ignoresSafeArea()
            .padding(.horizontal)
            .padding(.top)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: CustomBackButton())
            .navigationDestination(isPresented: $viewModel.loginActionSuccess, destination: {
                HomeView(viewModel: HomeVM())
            })
            
            PopupView(show: $viewModel.showPopUp)
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMsg),
                dismissButton: .default(Text("OK"))
            )
        }
        
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = LoginVM()
        LoginView(viewModel: viewModel)
    }
}


