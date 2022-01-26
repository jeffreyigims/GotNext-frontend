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
  func blueNavigation() -> some View { self.navigationBarColor(UIColor.systemBlue, textColor: UIColor.white) }
  func centeredContent() -> some View { self.modifier(CenteredContent()) }
  func leadingText() -> some View { self.modifier(LeadingText()) }
  func trailingText() -> some View { self.modifier(TrailingText()) }
  func navigationBarColor(_ backgroundColor: UIColor, textColor: UIColor) -> some View {
    self.modifier(NavigationBarModifier(backgroundColor: backgroundColor, textColor: textColor))
  }
}
