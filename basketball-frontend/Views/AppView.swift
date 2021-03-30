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
    
    if viewModel.currentScreen == "app" {
      GeometryReader { geometry in
        VStack {
          
          if viewModel.currentTab == "home" {
            HomeView(viewModel: viewModel, settingLocation: $viewModel.settingLocation, selectedLocation: $viewModel.selectedLocation)
          }
          
          else if viewModel.currentTab == "profile" {
            ProfileView(viewModel: viewModel, favorites: viewModel.favorites)
          }
          else if viewModel.currentTab == "invites" {
            InvitedGamesList(viewModel: viewModel)
          }
          if !viewModel.settingLocation {
            TabBarView(viewModel: viewModel, geometry: geometry)
          }
        }
      }
      .edgesIgnoringSafeArea(.bottom)
      .sheet(isPresented: $viewModel.showingSheet, content: sheetContent) 
    } else if viewModel.currentScreen == "login-splash" {
      SplashView()
    } else if viewModel.currentScreen == "create-user" {
      CreateUserView(viewModel: self.viewModel)
    } else if viewModel.currentScreen == "login" {
      LoginView(viewModel: self.viewModel)
    } else if viewModel.currentScreen == "landing" {
      LandingView(viewModel: self.viewModel).onAppear { self.viewModel.login(username: "jigims", password: "secret") }
    } else {
      SplashView()
        .onAppear { self.viewModel.login(username: "jxu", password: "secret") }
    }
  }
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView()
  }
}

extension AppView {
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
//        let a = print(pl)
        NavigationView {
          CreateFormView(viewModel: viewModel, location: MKMapItem(placemark: pl))
        }
      }
    //      NavigationView {
    //        CreateFormView(viewModel: viewModel, location: nil, placemark: viewModel.selectedLocation)
    //      }
    case .searchingUsers:
      UsersSearchView(viewModel: viewModel)
    }
  }
}
