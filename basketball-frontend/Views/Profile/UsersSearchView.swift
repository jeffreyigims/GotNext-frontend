//
//  UsersSearchView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 11/20/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI

struct UsersSearchView: View {
  @EnvironmentObject var viewModel: ViewModel
  @State var userSearch: String = ""
  
  var body: some View {
    let usSearch = Binding(
      get: { self.userSearch },
      set: {
        self.userSearch = $0;
        search()
      }
    )
//    NavigationView {
      VStack {
        SearchBarView<Users>(searchText: usSearch)
        UsersListView(users: viewModel.searchResults)
      }
      // .navigationBarTitle("Search Users")
//    }
//    .onAppear { search() }
  }
  
  func search() {
    viewModel.searchUsers(query: self.userSearch)
  }
}

struct UsersSearchView_Previews: PreviewProvider {
  static let viewModel: ViewModel = ViewModel()
  static var previews: some View {
    UsersSearchView().environmentObject(viewModel)
  }
}
