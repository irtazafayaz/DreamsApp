//
//  PaywallView.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 05/09/2023.
//

import SwiftUI
import RevenueCat

struct PaywallView: View {
    
    @Binding var isPaywallPresented: Bool
    @State var currentOffering: Offering?
    @State var selectedPackage: Package?
    @State var isHideLoader: Bool = true
    
    @State private var message = "Subscription Activated"
    @State private var showAlert = false
    @State var goBack = false
    
    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    
    func getPeriodTitle(_ period: SubscriptionPeriod?) -> String {
        guard let subPeriod = period else {
            return "NaN"
        }
        switch subPeriod.unit {
        case .day:
            return "Daily Premium"
        case .month:
            return "Monthly Premium"
        case .week:
            return "Weekly Premium"
        case .year:
            return "Yearly Premium"
        }
    }
    
    func getPeriodSubTitle(_ period: SubscriptionPeriod?) -> String {
        guard let subPeriod = period else {
            return "NaN"
        }
        switch subPeriod.unit {
        case .day:
            return ""
        case .month:
            return ""
        case .week:
            return ""
        case .year:
            return ""
        }
    }
    
    var body: some View {
        
        NavigationStack {
            
            VStack (alignment: .leading, spacing: 10) {
                Text("Unlock Unlimited Access")
                    .font(Font.custom(FontFamily.bold.rawValue, size: 30))
                    .foregroundColor(.black)
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .center) {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.black)
                        VStack(alignment: .leading) {
                            Text("Answers from GPT3.5")
                                .font(Font.custom(FontFamily.semiBold.rawValue, size: 20))
                                .foregroundColor(.black)
                        }
                    }
                    
                    HStack(alignment: .center) {
                        Image(systemName: "checkmark.icloud")
                            .foregroundColor(.black)
                        VStack(alignment: .leading) {
                            Text("Higher word limit")
                                .font(Font.custom(FontFamily.semiBold.rawValue, size: 20))
                                .foregroundColor(.black)
                        }
                    }

                    HStack(alignment: .center) {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.black)
                        VStack(alignment: .leading) {
                            Text("No Ads")
                                .font(Font.custom(FontFamily.semiBold.rawValue, size: 20))
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding()
                
                if isHideLoader {
                    if currentOffering != nil {
                        ForEach(currentOffering!.availablePackages) { pkg in
                            VStack(alignment: .leading) {
                                Button {
                                    selectedPackage = pkg
                                } label: {
                                    VStack(alignment: .leading) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(getPeriodTitle(pkg.storeProduct.subscriptionPeriod))
                                                    .foregroundColor(.black)
                                                .font(Font.custom(FontFamily.bold.rawValue, size: 18))
                                                HStack(spacing: 0) {
                                                    Text("\(pkg.storeProduct.localizedPriceString)")
                                                        .foregroundColor(.black.opacity(0.6))
                                                        .font(Font.custom(FontFamily.regular.rawValue, size: 18))
                                                }
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedPackage == pkg ? Color(hex: Colors.secondary.rawValue) : .gray.opacity(0.2))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color(hex: Colors.primary.rawValue), lineWidth: selectedPackage == pkg ? 2 : 0)
                                            )
                                    )
                                    .cornerRadius(10)
                                    .padding(.horizontal, 20)
                                }

                            }

                        }
                        
                        Button {
                            Purchases.shared.restorePurchases { (customerInfo, error) in
                                isHideLoader.toggle()
                                if let errorInfo = error {
                                    message = errorInfo.localizedDescription
                                    showAlert.toggle()
                                } else if Utilities.updateCustumerInCache(cust: customerInfo) {
                                    message = "Subscription Restored."
                                    showAlert.toggle()
                                    self.goBack = true
                                } else {
                                    message = "Nothing found to restore."
                                    showAlert.toggle()
                                }
                            }
                        } label: {
                            Text("Restore Purchase")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                } else {
                    VStack(alignment: .center) {
                        LoadingView().hidden(isHideLoader)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                }
                Spacer()
                Button {
                    isHideLoader = false
                    guard let pkg = selectedPackage else { return }
                    Purchases.shared.purchase(package: pkg) { (transaction, customerInfo, error, userCancelled) in
                        withAnimation {
                            isHideLoader = true
                        }
                        if let errorInfo = error {
                            message = errorInfo.localizedDescription
                            showAlert.toggle()
                        } else if Utilities.updateCustumerInCache(cust: customerInfo) {
                            message = "Subscription Purchased."
                            showAlert.toggle()
                            self.goBack = true
                        } else {
                            message = "No active subscriptions"
                            showAlert.toggle()
                        }
                    }
                } label: {
                    ZStack {
                        Rectangle()
                            .frame(height: 55)
                            .foregroundColor(Color(hex: Colors.primary.rawValue))
                            .cornerRadius(100)
                        Text("Buy Plan")
                            .font(Font.custom(FontFamily.semiBold.rawValue, size: 20))
                            .foregroundColor(.white)
                        
                    }
                }
                .disabled(!isHideLoader)
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .background(.white)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image("ic_back_arrow")
                                .foregroundColor(.black)
                        }
                    }
                })
            }
            .onAppear {
                Purchases.shared.getOfferings { offerings, error in
                    if let offer = offerings?.current, error == nil {
                        currentOffering = offer
                    }
                }
            }
            .alert(message, isPresented: $showAlert) {
                Button("OK", role: .cancel) {
                    if self.goBack {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct Paywall_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(isPaywallPresented: .constant(false))
    }
}

extension View {
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true: self.hidden()
        case false: self
        }
    }
}
