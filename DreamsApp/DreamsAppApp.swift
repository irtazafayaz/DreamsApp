//
//  DreamsAppApp.swift
//  DreamsApp
//
//  Created by Irtaza Fiaz on 23/02/2024.
//

import SwiftUI
import RevenueCat
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
       
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Constants.revenueCat)
        Utilities.updateSubscription()
        FirebaseApp.configure()
        
        return true
        
    }
}

@main
struct DreamsAppApp: App {
    
    @State private var showSplashScreen = true
    @StateObject var userViewModel = UserViewModel()
    @StateObject private var dataController = DataController()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().tableFooterView = UIView()
    }
    
    var body: some Scene {
        WindowGroup {
            if showSplashScreen {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            showSplashScreen = false
                        }
                    }
            } else {
                ContentView()
                    .environmentObject(userViewModel)
                    .environment(\.managedObjectContext, dataController.container.viewContext)
            }
        }
    }
}
