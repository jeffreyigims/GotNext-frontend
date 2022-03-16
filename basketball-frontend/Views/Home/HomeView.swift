//
//  HomeView.swift
//  basketball-frontend
//
//  Created by Matthew Cruz on 11/6/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var games: [Game]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing){
                MapView(viewModel: viewModel, selectedLocation: $viewModel.selectedLocation, gameFocus: $viewModel.game, settingLocation: $viewModel.focusOnGame).edgesIgnoringSafeArea(.all)
                VStack {
                    NotificationsButtonView(userGames: $viewModel.userGames, tap: viewModel.showInvites)
                    CreateGameButtonView(tap: viewModel.startCreating)
                }.padding()
                // content is passed as a closure to the bottom view
                BottomView(isOpen: $viewModel.isOpen, maxHeight: geometry.size.height * 0.84) {
                    GamesTableView(games: $games)
                }.edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static let viewModel: ViewModel = ViewModel()
    static var previews: some View {
        HomeView(games: .constant(viewModel.userGames)).environmentObject(viewModel)
    }
}
