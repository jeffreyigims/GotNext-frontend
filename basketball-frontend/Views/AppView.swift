//
//  AppView.swift
//  basketball-frontend
//
//  Created by Matthew Cruz on 11/4/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI
import MapKit

struct AppView: View {
  @ObservedObject var viewModel: ViewModel = ViewModel()
  
  var body: some View {
    pageContent().onAppear(perform: viewModel.tryLogin)
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
      GeometryReader { geometry in
        VStack {
          tabContent()
          if !viewModel.settingLocation {
            TabBarView(viewModel: viewModel, geometry: geometry)
          }
        }
      }
      .edgesIgnoringSafeArea(.bottom)
      .sheet(isPresented: $viewModel.showingSheet, onDismiss: viewModel.dismiss, content: sheetContent)
    case .loginSplash:
      SplashView()
    case .createUser:
      CreateUserView(viewModel: self.viewModel)
    case .login:
      LoginView(viewModel: self.viewModel)
    case .landing:
      LandingView(viewModel: self.viewModel) // .onAppear { self.viewModel.login(username: "jigims", password: "secret") }
    }
  }
  
  @ViewBuilder func tabContent() -> some View {
    switch viewModel.currentTab {
    case .home:
      HomeView(viewModel: viewModel, settingLocation: $viewModel.settingLocation, selectedLocation: $viewModel.selectedLocation)
    case .profile:
      ProfileView(viewModel: viewModel, favorites: viewModel.favorites)
    case .invites:
      InvitedGamesList(viewModel: viewModel)
    }
  }
  
  @ViewBuilder func sheetContent() -> some View {
    switch viewModel.activeSheet {
    case .creatingGame:
      CreateView(viewModel: viewModel)
    case .showingDetails:
      NavigationView {
        GameDetailsView(viewModel: self.viewModel, player: $viewModel.player, game: $viewModel.game)
          .navigationBarTitle("")
          .navigationBarHidden(true)
      }
    case .selectingLocation:
      if let pl = Helper.CLtoMK(placemark: viewModel.selectedLocation) {
        NavigationView {
          CreateFormView(viewModel: viewModel, location: MKMapItem(placemark: pl))
        }
      }
    case .searchingUsers:
      UsersSearchView(viewModel: viewModel)
    }
  }
}


