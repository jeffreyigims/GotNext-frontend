//
//  UsersListView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 11/10/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI

struct UsersListView: View {
  @EnvironmentObject var viewModel: ViewModel
  @State var users: [Users]
  
  var body: some View {
    //    ScrollView {
    //      LazyVStack {
    List(users) { user in
      UsersListRowView(user: user, isFavorited: user.favorite != -1)
    }
    //    .navigationBarTitleDisplayMode(.inline)
    //    .navigationBarTitle("Going Users")
    //      }
    //    }
  }
}

struct UsersListViewDynamic: View {
  @EnvironmentObject var viewModel: ViewModel
  @Binding var users: [Users]
  
  var body: some View {
    LazyVStack {
      //      VStack {
      ForEach(users) { user in
        UsersListRowView(user: user, isFavorited: user.favorite != -1).padding()
        Divider()
      }
    }
    .background(Color.white)
    .cornerRadius(15)
  }
}

struct UsersListRowView: View {
  @EnvironmentObject var viewModel: ViewModel
  let user: Users
  @State var isFavorited: Bool
  @State var alertShown: Bool = false
  var size: CGFloat = 38
  
  var body: some View {
    HStack {
      Image(systemName: "person.crop.circle.fill")
        .resizable()
        .frame(width: size, height: size)
        .scaledToFit()
      VStack(alignment: .leading) {
        Text(user.displayName()).font(.headline)
        Text(user.username).font(.subheadline)
      }
      Spacer()
      if (isFavorited) {
        Button(action: { self.alertShown.toggle() }) {
          Image(systemName: "star.fill")
            .resizable()
            .frame(width: size, height: size)
            .scaledToFit()
        }
      } else {
        Button(action: { self.favoriteActions() }) {
          Image(systemName: "star")
            .resizable()
            .frame(width: size, height: size)
            .scaledToFit()
        }
      }
    }
    .cornerRadius(15)
    .alert(isPresented: $alertShown) {
      Alert(title: Text("Unfavorite \(user.firstName)"),
            message: Text("Are you sure you want to unfavorite \(user.firstName)?"),
            primaryButton: .cancel(),
            secondaryButton: .destructive(Text("Unfavorite"), action: self.unfavoriteActions))
    }
  }
  
  func favoriteActions() {
    isFavorited = true
    viewModel.favorite(favoritee: user)
  }
  
  func unfavoriteActions() {
    isFavorited = false
    viewModel.unfavorite(user: user)
  }
}


struct UsersListView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ZStack {
        Color(UIColor.secondarySystemBackground)
          .ignoresSafeArea()
        UsersListViewDynamic(users: .constant(genericUsers)).padding([.leading, .trailing])
          //        UsersListViewDynamic(users: .constant(Array(repeating: genericUser, count: 40)))
          .padding([.leading, .trailing])
      }
      .navigationTitle("Preview Users")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}
