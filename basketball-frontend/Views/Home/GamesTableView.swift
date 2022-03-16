//
//  GamesTableView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 11/9/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI

struct GamesTableView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var games: [Game]
    
    var body: some View {
        //        let games = viewModel.groupGenericGameGroups(games: games)
        ScrollView {
            VStack(spacing: 0) {
                if viewModel.affiliatedGamesGrouped.count > 0 {
                    ForEach($viewModel.affiliatedGamesGrouped) { $gameGroup in
                        //                if games.count > 0 {
                        //                    ForEach(games) { gameGroup in
                        DateRow(date: gameGroup.date, games: gameGroup.games)
                    }
                }
                else {
                    Text("You have no current games in your stream. Check out games in your area above!")
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

struct DateRow: View {
    @EnvironmentObject var viewModel: ViewModel
    @State var sectionTitle: String = ""
    let date: Date
    @State var games: [Game]
    
    var body: some View {
        Section(header: SectionHeaderView(text: sectionTitle)) {
            ForEach($games) { $game in
                GameRow(game: $game).background(.white)
                Divider()
                    .padding([.leading, .trailing])
                    .background(Color(UIColor.secondarySystemBackground))
            }
        }
        .onAppear(perform: { self.sectionTitle = Helper.weekday(date: date) })
    }
}

struct SectionHeaderView: View {
    var text: String
    var body: some View {
        Text(text)
            .leadingText()
            .frame(maxWidth: .infinity)
            .padding(.leading, 10)
            .padding([.bottom, .top], 5)
            .background(Color(UIColor.secondarySystemBackground))
    }
}


struct GameRow: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var game: Game
    
    var body: some View {
        Button(action: { viewModel.showGame(game: game) }) {
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
}

@ViewBuilder func displayPlayerStatus(player: Player) -> some View {
    switch player.status {
    case .notGoing:
        Text(player.status.toString())
            .font(.subheadline)
            .frame(width: 77, height: 23)
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(4)
    case .invited:
        Text(player.status.toString())
            .font(.subheadline)
            .frame(width: 77, height: 23)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.systemGray, lineWidth: 1)
            )
            .background(.white)
            .foregroundColor(.black)
    case .maybe:
        Text(player.status.toString())
            .font(.subheadline)
            .frame(width: 77, height: 23)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.systemGray, lineWidth: 1)
            )
            .background(.white)
            .foregroundColor(.black)
    case .going:
        Text(player.status.toString())
            .font(.subheadline)
            .frame(width: 77, height: 23)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(4)
    }
}

struct GamePlayerStatusView: View {
    @Binding var game: Game
    var body: some View {
        HStack(spacing: 27) {
            HStack {
                Text("\(game.invited.count)")
                    .font(.footnote)
                    .foregroundColor(Color.systemGray)
                Image(systemName: "person.fill.xmark")
                    .scaledToFit()
                    .frame(width: 4, height: 4)
                    .foregroundColor(.systemRed)
                    .padding([.leading], 3)
            }
            HStack {
                Text("\(game.maybe.count)")
                    .font(.footnote)
                    .foregroundColor(Color.systemGray)
                Image(systemName: "person.fill.questionmark")
                    .scaledToFit()
                    .frame(width: 4, height: 4)
                    .foregroundColor(.systemGray)
                    .padding([.leading], 3)
            }
            HStack {
                Text("\(game.going.count)")
                    .font(.footnote)
                    .foregroundColor(Color.systemGray)
                Image(systemName: "person.fill.checkmark")
                    .scaledToFit()
                    .frame(width: 4, height: 4)
                    .foregroundColor(.systemGreen)
                    .padding([.leading], 3)
            }
        }
    }
}

struct GamesTableView_Previews: PreviewProvider {
    static let viewModel: ViewModel = ViewModel()
    static var previews: some View {
        GamesTableView(games: .constant(genericGames)).environmentObject(viewModel)
            .background(Color(UIColor.secondarySystemBackground))
    }
}

