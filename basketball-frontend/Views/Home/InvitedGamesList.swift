//
//  InvitedGamesList.swift
//  basketball-frontend
//
//  Created by Jeff Xu on 12/7/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import Foundation
import SwiftUI

struct InvitedGamesList: View {
    @EnvironmentObject var viewModel: ViewModel
    @State var groupedGames: [GenericGameGroup]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                //                if viewModel.invitedGamesGrouped.count > 0 {
                //                    ForEach(viewModel.invitedGamesGrouped) { gameGroup in
                if groupedGames.count > 0 {
                    ForEach(groupedGames) { gameGroup in
                        InvitedDateRow(date: gameGroup.date, games: gameGroup.games)
                    }
                }
                else {
                    Text("You are not currently invited to any games. Check out games in your area on the map!")
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                        .foregroundColor(.systemGray)
                        .centeredContent()
                        .padding(.top)
                }
            }
        }
    }
}

struct InvitedDateRow: View {
    @EnvironmentObject var viewModel: ViewModel
    @State var sectionTitle: String = ""
    let date: Date
    @State var games: [Game]
    
    var body: some View {
        Section(header: SectionHeaderView(text: sectionTitle)) {
            ForEach($games) { $game in
                InvitedGameRow(game: $game).background(.white)
                Divider()
                    .padding([.leading, .trailing])
                    .background(Color(UIColor.secondarySystemBackground))
            }
        }
        .navigationViewStyle(DefaultNavigationViewStyle())
        .onAppear(perform: { self.sectionTitle = Helper.getDateTimeProp(dateTime: date, prop: "EEEE") })
    }
}

struct InvitedGameRow: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var game: Game
    @State var showInvitedGameDetails: Bool = false
    
    var body: some View {
        NavigationLink(destination: InvitedGameDetailsView(viewModel: viewModel, game: $viewModel.game), isActive: $showInvitedGameDetails) { EmptyView() }
        Button(action: { showInvitedGameDetails(game: game) }) {
            HStack {
                VStack(alignment: .leading) {
                    // game title
                    Text(game.name)
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding([.bottom], 1)
                    // time and placemark
                    HStack {
                        Image(systemName: "clock").imageScale(.small)
                        Text(Helper.getDateTimeProp(dateTime: game.date, prop: "h:mm a,"))
                        Image(systemName: "mappin.and.ellipse").imageScale(.small)
                        Text(game.shortAddress)
                    }
                    .font(.footnote)
                    .foregroundColor(Color.systemGray)
                }
                Spacer()
                VStack(alignment: .leading) {
                    displayPlayerStatus(player: game.player)
                    Spacer()
                }
            }
        }
        .padding()
    }
    
    func showInvitedGameDetails(game: Game) -> () {
        viewModel.getGame(id: game.id)
        viewModel.game.player.status = Status.invited
        self.showInvitedGameDetails = true
    }
}

struct InvitedGameDetailsView: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var game: Game
    @State var sharingGame: Bool = false
    
    var body: some View {
        GameDetailsView(viewModel: viewModel, sharingGame: $sharingGame, game: $game)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) { Text("Game Details").foregroundColor(.white) }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { sharingGame.toggle() }) {
                        Image(systemName: shareButton)
                            .imageScale(.medium)
                    }
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarColor(UIColor(primaryColor), textColor: .white)
    }
}


struct InvitedGamesList_Previews: PreviewProvider {
    static let viewModel: ViewModel = ViewModel()
    static var previews: some View {
        NavigationView {
            InvitedGamesList(groupedGames: viewModel.invitedGamesGrouped).environmentObject(viewModel)
                .background(Color(UIColor.secondarySystemBackground))
        }
    }
}
