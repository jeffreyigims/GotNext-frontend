//
//  GotNext.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 3/1/22.
//  Copyright © 2022 Matthew Cruz. All rights reserved.
//

import SwiftUI
import AuthenticationServices

@main
struct GotNext: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @Environment(\.scenePhase) var scenePhase
    @ObservedObject var viewModel: ViewModel = ViewModel()
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(\.colorScheme, .light)
                .environmentObject(viewModel)
                .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .active:
                        UserDefaults(suiteName: "group.com.example.basketball-frontend")?.set(1, forKey: "count")
                        print("[INFO] resetting badge count")
                        UIApplication.shared.applicationIconBadgeNumber = 0
                        
//                        let provider = ASAuthorizationAppleIDProvider()
//                        provider.getCredentialState(forUserID: "currentUserIdentifier") { state, error in
//                          switch state {
//                          case .authorized:
//                            // credentials are valid.
//                            break
//                          case .revoked, .notFound:
//                            // credential revoked or not found, go to landing
//                              viewModel.currentScreen = Page.landing
//                          case .transferred:
//                              break
//                          @unknown default:
//                              break
//                          }
//                        }
                    case .background:
                        break
                    case .inactive:
                        break
                    @unknown default:
                        break
                    }
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    static var token: Data?
    
    // not called in SwiftUI
    func applicationWillEnterForeground(_ application: UIApplication) {}
    
    func applicationDidFinishLaunching(_ application: UIApplication) {}
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // application.registerForRemoteNotifications()
        return true
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Self.token = deviceToken
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("[INFO] received device token \(token)")
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("[INFO] did not receive device token with \(error.localizedDescription)")
    }
}
