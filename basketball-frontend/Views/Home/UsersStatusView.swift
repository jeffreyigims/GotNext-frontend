//
//  UsersStatusView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 12/16/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI

struct UsersStatusView: View {
  @EnvironmentObject var viewModel: ViewModel
  @Binding var users: [Users]
  let status: String
  
  var body: some View {
    UsersListView(users: users)
//      .navigationBarTitle(status + " Users")
  }
}

struct UsersStatusView_Previews: PreviewProvider {
  static let viewModel: ViewModel = ViewModel()
  static var previews: some View {
    UsersStatusView(users: .constant([Users]()), status: "Going").environmentObject(viewModel)
  }
}
