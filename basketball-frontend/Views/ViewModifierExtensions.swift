//
//  ViewModifierExtensions.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 1/19/22.
//  Copyright © 2022 Matthew Cruz. All rights reserved.
//

import SwiftUI

class HostingController<Content> : UIHostingController<Content> where Content : View {
    @objc override dynamic open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

struct CenteredContent: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
            Spacer()
        }
    }
}

struct HideNavigationBar: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationTitle("")
            .navigationBarHidden(true)
    }
}

struct LeadingText: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
        }
    }
}

struct TrailingText: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
        }
    }
}

struct PrimaryBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding([.top, .bottom], 10)
            .frame(maxWidth: .infinity)
            .background(primaryColor)
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}

struct RequestPushNotifications: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear(perform: {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound, .carPlay, .criticalAlert]) { (allowed, error) in
                    if allowed {
                        DispatchQueue.main.async {
                            UIApplication.shared.registerForRemoteNotifications()
                        }
                        print("[INFO] allowed notifications")
                    } else {
                        print("[INFO] received error for notifications request with \(String(describing: error))")
                    }
                }
            })
    }
}

// https://swiftuirecipes.com/blog/navigation-bar-styling-in-swiftui
struct NavigationBarModifier: ViewModifier {
    var backgroundColor: UIColor
    var textColor: UIColor
    
    init(backgroundColor: UIColor, textColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = .clear
        coloredAppearance.titleTextAttributes = [.foregroundColor: textColor]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: textColor]
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = textColor
    }
    
    func body(content: Content) -> some View {
        ZStack{
            content
            VStack {
                GeometryReader { geometry in
                    Color(self.backgroundColor)
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }
        }
    }
}

extension View {
    // navigation
    func blueNavigation() -> some View { self.navigationBarColor(UIColor.systemBlue, textColor: UIColor.white) }
    func customNavigation() -> some View { self.navigationBarColor(UIColor(primaryColor), textColor: UIColor.white) }
    
    // alignment
    func centeredContent() -> some View { self.modifier(CenteredContent()) }
    func leadingText() -> some View { self.modifier(LeadingText()) }
    func trailingText() -> some View { self.modifier(TrailingText()) }
    
    func primaryBackground() -> some View { self.modifier(PrimaryBackground()) }
    
    func hideNavigationBar() -> some View { self.modifier(HideNavigationBar()) }
    func requestPushNotifications() -> some View { self.modifier(RequestPushNotifications()) }
    func navigationBarColor(_ backgroundColor: UIColor, textColor: UIColor) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, textColor: textColor))
    }
}
