//
//  AppView.swift
//  basketball-frontend
//
//  Created by Matthew Cruz on 11/4/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI
import MapKit
import MessageUI

struct AppView: View {
  @ObservedObject var viewModel: ViewModel = ViewModel()
  init() {
    // for changing the color of the tabbar 
    //    UITabBar.appearance().isTranslucent = false
    //    UITabBar.appearance().backgroundColor = UIColor(named: "tabBarIconColor")
    //    UITabBar.appearance().barTintColor = UIColor(named: "tabBarIconColor")
  }
  
  var body: some View {
    pageContent()
      .fullScreenCover(isPresented: $viewModel.showingCover, onDismiss: viewModel.dismissCover, content: coverContent)
      .sheet(isPresented: $viewModel.showingSheet, onDismiss: viewModel.dismissSheet, content: sheetContent)
      .onAppear(perform: viewModel.tryLogin)
      .environmentObject(viewModel)
  }
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView()
  }
}

extension AppView {
  @ViewBuilder func pageContent() -> some View {
    switch viewModel.currentScreen {
    case .app:
      TabBarView().alert(isPresented: $viewModel.showAlert) { viewModel.alert! }
        .edgesIgnoringSafeArea(.bottom)
    case .loginSplash:
      SplashView()
    case .createUser:
      CreateUserView()
    case .login:
      LoginView()
    case .landing:
      LandingView()
    case .sendingMessage:
      MessageUIView(recipients: viewModel.contact, game: viewModel.game, completion: handleCompletion(_:))
    }
  }
  
  @ViewBuilder func tabContent() -> some View {
    switch viewModel.currentTab {
    case .home:
      HomeView(settingLocation: $viewModel.settingLocation, selectedLocation: $viewModel.selectedLocation)
    case .profile:
      ProfileView()
    case .invites:
      InvitedGamesList()
    }
  }
  
  @ViewBuilder func sheetContent() -> some View {
    NavigationView {
      switch viewModel.activeSheet {
      case .creatingGame:
        CreateView()
      case .showingDetails:
        GameDetailsView(viewModel: viewModel, player: $viewModel.player, game: $viewModel.game)
      case .selectingLocation:
        if let pl = Helper.CLtoMK(placemark: viewModel.selectedLocation) {
          CreateFormView(location: MKMapItem(placemark: pl))
        }
      case .searchingUsers:
        UsersSearchView()
      case .gameInvites:
        InvitedGamesList()
      case .discoveringFriends:
        DiscoverFriendsView()
      case .sendingMessage:
        MessageUIView(recipients: viewModel.contact, game: viewModel.game, completion: handleCompletion(_:))
      case .sharingGame:
        ShareSheetView(activityItems: ["Share this game"])
      }
    }
  }
  
  @ViewBuilder func coverContent() -> some View {
    switch viewModel.activeCover {
    case .addingFriends:
      Text("Hello World")
    case .showingFriends:
      Text("Hello World")
    case .editingProfile:
      ModalView(title: "My Profile") {
        EditProfileForm().alert(isPresented: $viewModel.showAlert) { viewModel.alert! }
      }
    }
  }
}

func handleCompletion(_ result: MessageComposeResult) {
  switch result {
  case .cancelled:
    break
  case .sent:
    break
  case .failed:
    break
  default:
    break
  }
}


