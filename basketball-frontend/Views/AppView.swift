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
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        pageContent()
            .fullScreenCover(isPresented: $viewModel.showingCover, onDismiss: viewModel.dismissCover, content: coverContent)
            .sheet(isPresented: $viewModel.showingSheet, onDismiss: viewModel.dismissSheet, content: sheetContent)
            .onAppear(perform: viewModel.tryAppleLogin)
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
            .requestPushNotifications()
        case .additionalInformation:
            AdditionalInformationView()
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
    
    @ViewBuilder func sheetContent() -> some View {
        NavigationView {
            switch viewModel.activeSheet {
            case .creatingGame:
                CreateView()
            case .showingDetails:
                Text("Game Details")
            case .selectingLocation:
                CreateFormView(location: viewModel.selectedLocation)
            case .searchingUsers:
                Text("Users Search View")
            case .gameInvites:
                InvitedGamesList(groupedGames: viewModel.invitedGamesGrouped)
            case .discoveringFriends:
                Text("Hello World")
            case .sendingMessage:
                MessageUIView(recipients: viewModel.contact, game: viewModel.game, completion: handleCompletion(_:))
            case .sharingGame:
                ShareSheetView(activityItems: ["Share this game"])
            }
        }
    }
    
    @ViewBuilder func coverContent() -> some View {
        switch viewModel.activeCover {
        case .creatingGame:
            ModalView(title: "Creating Game") {
                CreateView()
            }
        case .showingDetails:
            GameDetailsModalView(viewModel: viewModel)
        case .gameInvites:
            ModalView(title: "Game Invites") {
                InvitedGamesList(groupedGames: viewModel.invitedGamesGrouped)
            }
        case .selectingLocation:
            CreateFormView(location: viewModel.selectedLocation)
        case .addingFriends:
            Text("Hello World")
        case .showingFriends:
            Text("Hello World")
        case .editingProfile:
            ModalView(title: viewModel.user.username) {
                //                EditProfileForm().alert(isPresented: $viewModel.showAlert) { viewModel.alert! }
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


