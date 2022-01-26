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

  var body: some View {
    //		HStack{
    //			VStack(alignment: .leading){
    //				Image(systemName: "arrow.left")
    //					.font(.system(size: 24))
    //					.onTapGesture {
    //            self.viewModel.currentTab = Tab.home
    //					}
    //			}
    //			Text("Your Invites")
    //				.font(.largeTitle)
    //				.foregroundColor(Color("tabBarIconColor"))
    //				.padding()
    //		}
    List {
      ForEach(viewModel.getPlayerWithStatus(status: Status.invited)) { player in
        GameRow(player: player)
      }
    }.navigationBarTitle("Your Invites")
  }
}

struct InvitedGamesList_Previews: PreviewProvider {
  static let viewModel: ViewModel = ViewModel()
  static var previews: some View {
    InvitedGamesList().environmentObject(viewModel)
  }
}
