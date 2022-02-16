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
    @State var favoritees: [Users]
    @State var potentials: [Users]
    
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
                .padding(.top, 10)
            List {
                Section(header: Text("Added Me")) {
                    ForEach(favoritees) { user in
                        UsersListRowView(user: user, isFavorited: user.favorite != -1)
                    }
                }
                //                Section(header: Text("My Contacts")) {
                //                    ForEach(potentials) { user in
                //                        UsersListRowView(user: user, isFavorited: user.favorite != -1)
                //                    }
                //                    ContactsView(contacts: viewModel.contacts)
                //                }
            }        .listStyle(PlainListStyle())
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
        NavigationView {
            DiscoverFriendsView(favoritees: [Users](), potentials: [Users]()).environmentObject(viewModel)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {}) {
                            Image(systemName: chevronDown)
                        }
                    }
                    ToolbarItem(placement: .principal) { Text("Discover Friends").foregroundColor(.white) }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .edgesIgnoringSafeArea(.bottom)
                .customNavigation()
        }
    }
}
