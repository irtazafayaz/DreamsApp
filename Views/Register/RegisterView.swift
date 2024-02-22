//
//  RegisterView.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 26/05/2023.
//

import SwiftUI

struct RegisterView: View {
    
    @ObservedObject private var viewModel: RegisterUserVM
    
    init(viewModel: RegisterUserVM) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Hello There")
                .font(Font.custom(FontFamily.bold.rawValue, size: 32))
                .frame(alignment: .leading)
            
            ScrollView {
                
                Text("Please enter your email & password to create an account.")
                    .font(Font.custom(FontFamily.regular.rawValue, size: 18))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 10)
                    .lineLimit(2)
                
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
                
                // MARK: Confirm Password Text Field
                VStack(alignment: .leading) {
                    Text("Confirm Password")
                        .font(.headline)
                    HStack {
                        if viewModel.isConfirmPasswordVisible {
                            TextField("Password", text: $viewModel.confirmPassword)
                        } else {
                            SecureField("Password", text: $viewModel.confirmPassword)
                        }
                        Button(action: {
                            viewModel.isConfirmPasswordVisible.toggle()
                        }) {
                            Image(systemName: viewModel.isConfirmPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                .foregroundColor(Color(hex: Colors.primary.rawValue))
                        }
                    }
                    .padding(.bottom, 20)
                    .underlinedTextFieldStyle()
                }
                .padding(.top, 10)
                
                // MARK: CheckBox Agreement
                HStack {
                    Button(action: {
                        viewModel.isAgreed.toggle()
                    }) {
                        Image(viewModel.isAgreed ? "ic_checkbox_filled" : "ic_checkbox")
                            .foregroundColor(viewModel.isAgreed ? .green : .gray)
                    }
                    Text("I agree to School AI Public Agreement, Terms, & Privacy Policy.")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .lineLimit(3)
                        .onTapGesture {
                        }
                }
                .padding(.top, 10)
                
                Divider()
                    .padding(.top, 20)
                
                NavigationLink(destination: LoginView(viewModel: LoginVM())) {
                    HStack(alignment: .center) {
                        Text("Already Have an account?")
                            .font(Font.custom(FontFamily.medium.rawValue, fixedSize: 16))
                            .foregroundColor(Color(hex: Colors.labelDark.rawValue))
                        Text("Login")
                            .font(Font.custom(FontFamily.bold.rawValue, fixedSize: 16))
                            .foregroundColor(Color(hex: Colors.primary.rawValue))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)
                }
                
            }
            Button(action: {
                viewModel.moveToCompleteProfile()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 100)
                        .foregroundColor(Color(hex: Colors.primary.rawValue))
                        .shadow(color: Color.green.opacity(0.25), radius: 24, x: 4, y: 8)
                        .frame(height: 65)
                        .padding()
                    
                    Text("Continue ")
                        .foregroundColor(.white)
                        .font(.system(size: 18, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
                .padding(.bottom, 10)
            }
            
        }
        .ignoresSafeArea()
        .padding(.horizontal)
        .padding(.top)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: CustomBackButton())
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMsg),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(viewModel: RegisterUserVM())
    }
}
