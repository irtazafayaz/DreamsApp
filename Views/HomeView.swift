//
//  HomeView.swift
//  AiChatBot
//
//  Created by Irtaza Fiaz on 29/05/2023.
//

import SwiftUI

struct HomeView: View {
    
    @State private var selectedTab: Int = 0
    @State private var title = "School AI"
    @State var isPaywallPresented = false
    @ObservedObject private var viewModel: HomeVM
    @FetchRequest(sortDescriptors: []) var chatHistory: FetchedResults<ChatHistory>
    
    init(viewModel: HomeVM) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                TabView(selection: $selectedTab) {
                    StartChatView()
                        .tabItem {
                            Image("ic_tab_chat")
                            Text("Chat")
                        }
                        .tag(0)
                    ChatAssistantView()
                        .tabItem {
                            Image("ic_tab_assistant")
                            Text("AI Assistants")
                        }
                        .tag(1)
                    ChatHistoryView()
                        .tabItem {
                            Image("ic_tab_history")
                            Text("History")
                        }
                        .tag(2)
                    ProfileView()
                        .tabItem {
                            Image("ic_tab_people")
                            Text("Account")
                        }
                        .tag(3)
                }
                .accentColor(Color(hex: Colors.primary.rawValue))
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Image("ic_app_logo_small")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                    
                })
            }
            .onChange(of: selectedTab) { newTab in
                switch newTab {
                case 0:
                    title = "School AI"
                case 1:
                    title = "AI Assistants"
                case 2:
                    title = "History"
                case 3:
                    title  = "Account"
                default:
                    title = "School AI"
                }
            }
            .onAppear {
                isPaywallPresented = true
            }
            .navigationDestination(isPresented: $isPaywallPresented, destination: {
                PaywallView(isPaywallPresented: $isPaywallPresented)
            })
        }
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: HomeVM())
    }
}
