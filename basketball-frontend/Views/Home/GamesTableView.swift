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

  var body: some View {
//    VStack(alignment: .leading){
//      Text("Your Games")
//        .font(.system(size: 28))
//        .bold()
//        .foregroundColor(.white)
//        .padding(.bottom, 5)
//    }
      List {
        if viewModel.groupedPlayers.count > 0 {
          ForEach(viewModel.groupedPlayers, id: \.key) { player in
            DateRow(date: player.key, players: player.value)
          }
        }
        else {
          Text("No Current Games \n Checkout Games Nearby Above!")
            .font(.system(size: 24))
            .foregroundColor(.red)
        }
    }
      .navigationBarTitle("") // title must be set to use hidden property
      .navigationBarHidden(true)
  }
}

struct DateRow: View {
  @EnvironmentObject var viewModel: ViewModel
  let date: String
  let players: [Player]
  
  var body: some View {
    Section(header:
              Text(Helper.weekday(date: date))
    ) {
      ForEach(players) { player in
        GameRow(player: player)
      }
    }.textCase(nil)
  }
}


struct GameRow: View {
  @EnvironmentObject var viewModel: ViewModel
  let player: Player
  
  var body: some View {
    Button(action: { viewModel.showGame(game: player.game.data, player: player) }) {
      VStack {
        HStack {
          Text(player.game.data.name).bold()
          Spacer()
          Text(player.status.toString())
        }.padding(.bottom, 5)
        HStack {
          Text(player.game.data.onTime())
          Spacer()
          Image(systemName: "arrow.right")
        }
      }.padding(10)
    }
  }
}

struct CustomHeader: View {
  let name: String
  var body: some View {
    VStack {
      Spacer()
      HStack {
        Text(name)
        Spacer()
      }
      Spacer()
    }
    .padding(0)
    .frame(maxWidth: .infinity)
    .background(Color("tabBarIconColor"))
  }
}

struct GamesTableView_Previews: PreviewProvider {
  static let viewModel: ViewModel = ViewModel()
  static var previews: some View {
    GamesTableView().environmentObject(viewModel)
  }
}

