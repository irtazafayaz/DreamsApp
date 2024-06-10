//
//  HomeView.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 29/05/2023.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = ChatHistoryVM()
//    @EnvironmentObject var sessionManager: SessionManager
    
    @State private var selectedTab: Int = 0
    @State private var title = "AI Dream Interpreter"
    @State var isPaywallPresented = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                TabView(selection: $selectedTab) {
                    StartChatView(groupedMessages: viewModel.groupedMessages)
                        .tabItem {
                            Image("ic_tab_chat")
                            Text("Your Dream")
                        }
                        .tag(0)
                    ChatHistoryView(viewModel: viewModel)
                        .tabItem {
                            Image("ic_tab_history")
                            Text("Your Dream History")
                        }
                        .tag(1)
                    ProfileView()
                        .tabItem {
                            Image("ic_tab_people")
                            Text("Account")
                        }
                        .tag(2)
                }
                .accentColor(Color(hex: Colors.primary.rawValue))
            }
            .onAppear { viewModel.fetchMessagesGroupedByCreatedAt(email: SessionManager.shared.currentUser?.email ?? "NaN") }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Image("ic_app_logo_gray")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(Color(hex: Colors.primary.rawValue))
                })
            }
            .onChange(of: selectedTab) { newTab in
                switch newTab {
                case 0:
                    title = "AI Dream Interpreter"
                case 1:
                    title = "History"
                case 2:
                    title  = "Account"
                default:
                    title = "Dream In"
                }
            }
            .onAppear {
                //                isPaywallPresented = true
            }
            .navigationDestination(isPresented: $isPaywallPresented, destination: {
                PaywallView(isPaywallPresented: $isPaywallPresented)
            })
        }
        
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
