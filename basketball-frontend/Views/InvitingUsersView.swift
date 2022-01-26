//
//  InvitingUsersView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 11/11/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI

struct InvitingUsersView: View {
  @EnvironmentObject var viewModel: ViewModel

  var body: some View {
    VStack {
//      List {
//        ForEach(viewModel.favorites, id: \.favorite.id) { arg in
//          InvitingUsersRowView(favorite: arg.favorite, invited: arg.invited)
//        }
//      }
//      .navigationBarTitle("Invite Favorites")
//          .navigationBarItems(trailing:
//                                NavigationLink(destination: InvitingContactsView(
//                                                viewModel: viewModel, searchResults: $viewModel.contactsFiltered))
//                                {
//                                  Text("Invite Contacts")
//                                })
      NavigationLink(destination: InvitingContactsView())
      {
        Text("Invite Contacts")
      }
    }
  }
}

struct InvitingUsersRowView: View {
  @EnvironmentObject var viewModel: ViewModel
  let favorite: Favorite
  @State var invited: Bool
  
  var body: some View {
    HStack {
      Text(favorite.user.data.displayName())
      Spacer()
      Button(action: {
        inviteFavorite()
      }) {
        Text(invited ? "Invited" : "Invite")
          .padding()
          .background(invited ? Color.gray : Color.red)
          .foregroundColor(.black)
          .cornerRadius(40)
          .padding(.leading)
      }
    }.alert(isPresented: $viewModel.showAlert) {
      viewModel.alert!
    }
  }
  func inviteFavorite() {
    viewModel.inviteUser(status: "invited", userId: favorite.user.data.id, gameId: viewModel.game.id)
    invited = true
  }
}

struct InvitingUsersView_Previews: PreviewProvider {
  static let viewModel: ViewModel = ViewModel()
  static var previews: some View {
    InvitingUsersView().environmentObject(viewModel)
  }
}
