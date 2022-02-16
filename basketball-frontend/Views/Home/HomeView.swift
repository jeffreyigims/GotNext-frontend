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
    @State var isOpen: Bool = false
    @Binding var games: [Game]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing){
                MapView(viewModel: viewModel, games: $viewModel.gameAnnotations, selectedLocation: $viewModel.selectedLocation, moving: .constant(false), gameFocus: $viewModel.game, settingLocation: false).edgesIgnoringSafeArea(.all)
                VStack {
                    NotificationsButtonView(invitedGames: $viewModel.invitedGames, tap: viewModel.showInvites)
                    CreateGameButtonView(tap: viewModel.startCreating)
                }.padding()
                // content is passed as a closure to the bottom view
                BottomView(isOpen: self.$isOpen, maxHeight: geometry.size.height * 0.84) {
                    GamesTableView(games: $games)
                }.edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct SelectLocationButtonView: View {
    var tapAction: () -> ()
    var body: some View {
        Button(action: tapAction ) {
            Text("Select Location")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color("primaryButtonColor"))
                .foregroundColor(.black)
                .cornerRadius(20)
                .padding([.trailing, .leading])
        }
    }
}

struct CancelSelectLocationButtonView: View {
    var tapAction: () -> ()
    var body: some View {
        Button(action: tapAction) {
            Text("Cancel")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color("secondaryButtonColor"))
                .foregroundColor(.black)
                .cornerRadius(20)
                .padding([.trailing, .leading])
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static let viewModel: ViewModel = ViewModel()
    static var previews: some View {
        HomeView(games: .constant(viewModel.userGames)).environmentObject(viewModel)
    }
}
