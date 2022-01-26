//
//  DiscoverFriends.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 4/7/21.
//  Copyright © 2021 Matthew Cruz. All rights reserved.
//

import SwiftUI
import MessageUI

struct DiscoverFriendsView: View {
  @EnvironmentObject var viewModel: ViewModel
  @State var userSearch: String = ""
  @State var editing: Bool = false
  
  var body: some View {
    let genericSearch = Binding(
      get: { self.userSearch },
      set: {
        self.userSearch = $0;
        search()
      }
    )
    VStack {
      SimpleSearchBarView<Users>(searchText: genericSearch)
      ScrollView {
        Text("Added Me")
          .font(.title2)
          .bold()
          .padding()
          .leadingText()
        UsersListViewDynamic(users: $viewModel.potentials)
          .padding([.leading, .trailing])
        Text("From Contacts")
          .font(.title2)
          .bold()
          .padding()
          .leadingText()
        ContactsView(contacts: viewModel.contacts)
          .padding([.leading, .trailing])
      }
    }.gesture(DragGesture().onChanged { _ in
      UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    })
  }
  
  func search() {
    viewModel.searchUsers(query: self.userSearch)
  }
}

struct DiscoverFriendsView_Previews: PreviewProvider {
  static let viewModel: ViewModel = ViewModel()
  static var previews: some View {
    DiscoverFriendsView().environmentObject(viewModel)
  }
}
