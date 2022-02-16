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
        GamesTableView(games: $viewModel.invitedGames)
            .navigationBarTitle("Invites")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct InvitedGamesList_Previews: PreviewProvider {
    static let viewModel: ViewModel = ViewModel()
    static var previews: some View {
        NavigationView {
            InvitedGamesList().environmentObject(viewModel)
        }
    }
}
