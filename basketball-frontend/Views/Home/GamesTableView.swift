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
        let games = viewModel.groupGames(games: games)
        List {
            //                        if viewModel.groupedGamesGoing.count > 0 {
            //                            ForEach(viewModel.groupedGamesGoing, id: \.key) { gameGroup in
            if games.count > 0 {
                ForEach(games, id: \.key) { gameGroup in
                    DateRow(date: gameGroup.key, games: gameGroup.value)
                }
            }
            else {
                Text("You have no current games in your stream. Check out games in your area above!")
                    .multilineTextAlignment(.center)
                    .font(.footnote)
                    .foregroundColor(.systemGray)
                    .centeredContent()
            }
        }
        .listStyle(GroupedListStyle())
    }
}

struct DateRow: View {
    @EnvironmentObject var viewModel: ViewModel
    let date: String
    let games: [Game]
    
    var body: some View {
        Section(header: SectionHeaderView(text: Helper.weekday(date: date))) {
            ForEach(games) { game in
                GameRow(game: game)
            }
        }
        .textCase(nil)
    }
}

struct SectionHeaderView: View {
    var text: String
    var body: some View {
        Text(text)
            .frame(maxHeight: .infinity)
//            .background(Color(UIColor.secondarySystemBackground))
    }
}


struct GameRow: View {
    @EnvironmentObject var viewModel: ViewModel
    let game: Game
    @State var address: String = ""
    
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
                        Text(Helper.getDateTimeProp(dateTime: Helper.toTime(time: game.time), prop: "h:mm a,"))
                        Image(systemName: "mappin.and.ellipse").imageScale(.small)
                        Text(address)
                    }
                    .font(.footnote)
                    .foregroundColor(Color.systemGray)
                    //                    Text(game.description)
                    //                        .font(.footnote)
                    //                        .foregroundColor(Color.systemGray)
                    //                        .multilineTextAlignment(.leading)
                    HStack {
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
                Spacer()
                VStack(alignment: .trailing) {
                    displayPlayerStatus(player: game.player)
                }
            }
        }
        .onAppear(perform: getAddress)
        //        .padding([.leading, .trailing], 0)
    }
    func getAddress() {
        Helper.coordinatesToPlacemark(latitude: game.latitude, longitude: game.longitude) { placemark in
            self.address = Helper.getAddressTable(placemark: placemark)
        }
    }
}

@ViewBuilder func displayPlayerStatus(player: Player?) -> some View {
    Text(player?.status.toString() ?? "Unknown")
        .font(.footnote)
        .padding(3)
        .foregroundColor(.white)
        .background(Color.systemGreen)
        .cornerRadius(14)
}

struct GamesTableView_Previews: PreviewProvider {
    static let viewModel: ViewModel = ViewModel()
    static var previews: some View {
        GamesTableView(games: .constant(genericGames)).environmentObject(viewModel)
    }
}

