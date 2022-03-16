//
//  UsersListView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 11/10/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI

struct UsersListViewDynamic: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var users: [Users]
    
    var body: some View {
        List(users) { user in
            UsersListRowView(user: user, isFavorited: user.favorite != -1)
                .padding([.top, .bottom], 8)
        }
        .listStyle(PlainListStyle())
    }
}

struct UsersListRowView: View {
    @EnvironmentObject var viewModel: ViewModel
    let user: Users
    @State var isFavorited: Bool
    @State var alertShown: Bool = false
    
    var body: some View {
        HStack {
            profilePic(profilePic: user.profilePicture, size: profileIconSize)
            VStack(alignment: .leading) {
                Text(user.displayName()).font(.headline)
                Text(user.username).font(.subheadline).foregroundColor(Color(UIColor.darkGray))
            }
            Spacer()
            if viewModel.user.id != user.id {
                if (isFavorited) {
                    Button(action: { self.alertShown.toggle() }) {
                        Text("Favorited")
                            .font(.subheadline)
                            .frame(width: 77, height: 23)
                            .background(primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }.buttonStyle(PlainButtonStyle())
                } else {
                    Button(action: { self.favoriteActions() }) {
                        Text("Favorite")
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
    static let viewModel: ViewModel = ViewModel()
    static var previews: some View {
        NavigationView {
            ZStack {
                Color(UIColor.secondarySystemBackground)
                    .ignoresSafeArea()
                UsersListViewDynamic(users: .constant(genericUsers)).environmentObject(viewModel)
            }
            .navigationTitle("Preview Users")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
