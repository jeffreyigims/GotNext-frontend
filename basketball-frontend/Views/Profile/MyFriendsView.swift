//
//  MyFriendsView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 1/19/22.
//  Copyright © 2022 Matthew Cruz. All rights reserved.
//

import SwiftUI

struct MyFriendsView: View {
    @EnvironmentObject var viewModel: ViewModel
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
            UsersListViewDynamic(users: $searchResults)
        }
        .gesture(DragGesture().onChanged { _ in
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        })
    }
    
    func search() {
        searchResults = userSearch == "" ? viewModel.user.favorites : viewModel.user.favorites.filter { fav in fav.firstName.localizedCaseInsensitiveContains(userSearch) || fav.lastName.localizedCaseInsensitiveContains(userSearch) ||  fav.username.localizedCaseInsensitiveContains(userSearch)}
    }
}

struct MyFriendsView_Previews: PreviewProvider {
    static let viewModel: ViewModel = ViewModel()
    static var previews: some View {
        NavigationView {
            MyFriendsView(searchResults: genericUsers).environmentObject(viewModel)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {}) {
                            Image(systemName: chevronDown)
                        }
                    }
                    ToolbarItem(placement: .principal) { Text("My Favorites").foregroundColor(.white) }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .edgesIgnoringSafeArea(.bottom)
                .customNavigation()
        }
    }
}
