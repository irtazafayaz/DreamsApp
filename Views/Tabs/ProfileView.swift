//
//  ProfileView.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 05/09/2023.
//

import SwiftUI

struct ProfileView: View {
    
    @State var isPaywallPresented = false
    @State private var showTerms = false
    @State private var showPrivacy = false
    @ObservedObject private var viewModel: ProfileVM
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var sessionManager: SessionManager

    init () {
        self.viewModel = ProfileVM()
    }
    
    var body: some View {
        
        ZStack {
            VStack(alignment: .leading) {
                
                if !UserDefaults.standard.isProMemeber {
                    Button {
                        isPaywallPresented.toggle()
                    } label: {
                        HStack(alignment: .center) {
                            Image("ic_paywall")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                            
                            VStack(alignment: .leading) {
                                Text("Upgrade to PRO!")
                                    .font(Font.custom(FontFamily.bold.rawValue, size: 20))
                                    .foregroundColor(Color(hex: "#FFFFFF"))
                                Text("Enjoy all benefits without restrictions")
                                    .font(Font.custom(FontFamily.semiBold.rawValue, size: 12))
                                    .foregroundColor(Color(hex: "#FFFFFF"))
                            }
                            Spacer()
                            Image("ic_arrow_right")
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(RoundedCorners(
                            tl: 10,
                            tr: 10,
                            bl: 10,
                            br: 10
                        ).fill(Color(hex: Colors.primary.rawValue)))
                        .padding(.top, 20)
                    }
                }
                
                DividerWithLabel(label: "About")
                    .padding(.top, 30)
                
                Button {
                    showTerms.toggle()
                } label: {
                    HStack(alignment: .center) {
                        Image("ic_help_center")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 17, height: 20)
                        Text("Terms and Conditions")
                            .font(Font.custom(FontFamily.bold.rawValue, size: 18))
                            .foregroundColor(Color(hex: Colors.labelDark.rawValue))
                            .padding(.leading, 5)
                        Spacer()
                        Image("ic_arrow_right")
                            .foregroundColor(.black)
                    }
                    .padding(.top, 20)
                }
                
                Button {
                    showPrivacy.toggle()
                } label: {
                    HStack(alignment: .center) {
                        Image("ic_privacy_policy")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 17, height: 20)
                        Text("Privacy Policy")
                            .font(Font.custom(FontFamily.bold.rawValue, size: 18))
                            .foregroundColor(Color(hex: Colors.labelDark.rawValue))
                            .padding(.leading, 5)
                        Spacer()
                        Image("ic_arrow_right")
                            .foregroundColor(.black)
                    }
                    .padding(.top, 20)
                }
                
                Button {
                    Task {
                            await SessionManager.shared.logout()
                            UserDefaults.standard.userEmail = ""
                        }
                } label: {
                    HStack(alignment: .center) {
                        Image(systemName: "person.slash.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 17, height: 20)
                        Text("Logout")
                            .font(Font.custom(FontFamily.bold.rawValue, size: 18))
                            .foregroundColor(.red)
                            .padding(.leading, 5)
                        Spacer()
                    }
                    .padding(.top, 20)
                }
                
                Button {
                    viewModel.showDeletePopUp = true
                } label: {
                    HStack(alignment: .center) {
                        Image(systemName: "trash.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 17, height: 20)
                        Text("Delete Account")
                            .font(Font.custom(FontFamily.bold.rawValue, size: 18))
                            .foregroundColor(.red)
                            .padding(.leading, 5)
                        Spacer()
                    }
                    .padding(.top, 20)
                }
                .alert(isPresented: $viewModel.showDeletePopUp) {
                    Alert(
                        title: Text("Delete Account"),
                        message: Text("Are you sure you want to delete your account? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            SessionManager.shared.deleteUserAccount { result in
                                switch result {
                                case .success():

                                    presentationMode.wrappedValue.dismiss()
                                case .failure(let error):
                                    // Handle error, e.g., show an error message
                                    print("Error deleting account: \(error.localizedDescription)")
                                }
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }


                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $isPaywallPresented, destination: {
                PaywallView(isPaywallPresented: $isPaywallPresented)
            })
            .sheet(isPresented: $showTerms, content: {
                SharedWebView(pageType: .terms)
            })
            .sheet(isPresented: $showPrivacy, content: {
                SharedWebView(pageType: .privacy)
            })
            PopupView(show: $viewModel.showPopUp)
        }
        
        
    }
    
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
