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
    @Binding var searchResults: [Users]
    @State var contacts: [Contact]
    
    var body: some View {
        let genericSearch = Binding(
            get: { self.userSearch },
            set: {
                self.userSearch = $0;
                search()
            }
        )
        VStack(alignment: .leading) {
            SimpleSearchBarView<Users>(searchText: genericSearch)
                .padding(.top, 10)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    
                    // users who have favorited the user should appear first
                    if favoritees.count > 0 {
                        DiscoverFriendsSectionHeaderView(input: "Favorited Me")
                    }
                    ForEach(favoritees) { user in
                        UsersListRowView(user: user, isFavorited: user.favorite != -1)
                            .padding()
                            .background(.white)
                        Divider()
                            .padding([.leading, .trailing])
                            .background(Color(UIColor.secondarySystemBackground))
                    }
                    
                    // users from the user contacts should then appear
                    if potentials.count > 0 {
                        DiscoverFriendsSectionHeaderView(input: "From Contacts")
                    }
                    ForEach(potentials) { user in
                        UsersListRowView(user: user, isFavorited: user.favorite != -1)
                            .padding()
                            .background(.white)
                        Divider()
                            .padding([.leading, .trailing])
                            .background(Color(UIColor.secondarySystemBackground))
                    }
                    
                    // there were no results in favorites or contact potentials so global search
                    if favoritees.count == 0 && potentials.count == 0 {
                        if searchResults.count > 0 {
                            DiscoverFriendsSectionHeaderView(input: "Add Favorites")
                        }
                        ForEach(searchResults) { user in
                            UsersListRowView(user: user, isFavorited: user.favorite != -1)
                                .padding()
                                .background(.white)
                            Divider()
                                .padding([.leading, .trailing])
                                .background(Color(UIColor.secondarySystemBackground))
                        }
                    }
                    
                    // finally display contact list
                    if contacts.count > 0 {
                        DiscoverFriendsSectionHeaderView(input: "Contact List")
                    }
                    ForEach(contacts) { contact in
                        ContactsRowView(contact: contact)
                            .padding()
                            .background(.white)
                        Divider()
                            .padding([.leading, .trailing])
                            .background(Color(UIColor.secondarySystemBackground))
                    }
                    
                    // there were no results from local or global searches
                    if favoritees.count == 0 && potentials.count == 0 && contacts.count == 0 && viewModel.searchResults.count == 0 {
                        Text("There are no results for your current search")
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .foregroundColor(.systemGray)
                            .centeredContent()
                            .padding(.top)
                    }
                }
                
            }
            Spacer()
        }.gesture(DragGesture().onChanged { _ in
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        })
    }
    
    func search() {
        self.favoritees = userSearch == "" ? viewModel.favoriteesNotFavorited : viewModel.favoriteesNotFavorited.filter { user in user.firstName.localizedCaseInsensitiveContains(userSearch) || user.lastName.localizedCaseInsensitiveContains(userSearch) ||  user.username.localizedCaseInsensitiveContains(userSearch)}
        self.potentials = userSearch == "" ? viewModel.potentials : viewModel.potentials.filter { user in user.firstName.localizedCaseInsensitiveContains(userSearch) || user.lastName.localizedCaseInsensitiveContains(userSearch) ||  user.username.localizedCaseInsensitiveContains(userSearch)}
        self.contacts = userSearch == "" ? viewModel.contactPotentials : viewModel.contactPotentials.filter { contact in contact.firstName.localizedCaseInsensitiveContains(userSearch) || contact.lastName?.localizedCaseInsensitiveContains(userSearch) == true}
        viewModel.searchUsers(query: self.userSearch)
    }
}

struct DiscoverFriendsSectionHeaderView: View {
    var input: String
    
    var body: some View {
        Text(input)
            .font(.title3)
            .bold()
            .foregroundColor(.black)
            .padding([.leading, .top])
            .padding(.bottom, 8)
    }
}

struct DiscoverFriendsView_Previews: PreviewProvider {
    static let viewModel: ViewModel = ViewModel()
    static var previews: some View {
        NavigationView {
            DiscoverFriendsView(favoritees: genericUsers, potentials: genericUsers, searchResults: .constant(genericUsers), contacts: genericContacts).environmentObject(viewModel)
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
