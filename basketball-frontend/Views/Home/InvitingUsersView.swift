//
//  InvitingUsersView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 11/11/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI

struct InvitingUsersView: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var game: Game
    @State var searchResults: [Users]
    @State var userSearch: String = ""
    
    var body: some View {
        let favoritesSearch = Binding(
            get: { self.userSearch },
            set: {
                self.userSearch = $0;
                search()
            }
        )
        VStack {
            SimpleSearchBarView<Users>(searchText: favoritesSearch)
                .padding(.top, 10)
            InvitingUsersListViewDynamic(users: $searchResults, game: $game)
        }
        .gesture(DragGesture().onChanged { _ in
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        })
    }
    func search() {
        searchResults = userSearch == "" ? viewModel.user.favorites : viewModel.user.favorites.filter { fav in fav.firstName.localizedCaseInsensitiveContains(userSearch) || fav.lastName.localizedCaseInsensitiveContains(userSearch) ||  fav.username.localizedCaseInsensitiveContains(userSearch)}
    }
}

struct InvitingUsersListViewDynamic: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var users: [Users]
    @Binding var game: Game
    
    var body: some View {
        List(users) { user in
            InvitingUsersListRowView(game: $game, user: user)
                .padding([.top, .bottom], 8)
        }
        .listStyle(PlainListStyle())
    }
}

struct InvitingUsersListRowView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var game: Game
    let user: Users
    @State var isInvited: Bool = false
    var size: CGFloat = 38
    
    var body: some View {
        HStack {
            profilePic(profilePic: user.profilePicture, size: profileIconSize)
            VStack(alignment: .leading) {
                Text(user.displayName()).font(.headline)
                Text(user.username).font(.subheadline).foregroundColor(Color(UIColor.darkGray))
            }
            Spacer()
            if (isInvited) {
                Text("Invited")
                    .font(.subheadline)
                    .frame(width: 77, height: 23)
                    .background(primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(4)
            } else {
                Button(action: self.inviteActions ) {
                    Text("Invite")
                        .font(.subheadline)
                        .frame(width: 77, height: 23)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.systemGray, lineWidth: 1)
                        )
                        .background(.white)
                        .foregroundColor(.black)
                }.buttonStyle(PlainButtonStyle())
            }
        }
    }
    func inviteActions() {
        isInvited = true
        viewModel.invite(user: user, game: game)
    }
}

struct InvitingUsersView_Previews: PreviewProvider {
    static let viewModel: ViewModel = ViewModel()
    static var previews: some View {
        SheetView(title: "Invite Friends") {
            InvitingUsersView(viewModel: viewModel, game: .constant(genericGame), searchResults: genericUsers).environmentObject(viewModel)
        }
    }
}
