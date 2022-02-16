//
//  ProfileView.swift
//  basketball-frontend
//
//  Created by Matthew Cruz on 11/6/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI
import PhotoSelectAndCrop

struct ProfileView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State var editingProfile = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if let profilePicture: String = viewModel.user.profilePicture {
                    AsyncImage(url: URL(string: profilePicture)) { image in
                        image
                            .resizable()
                            .frame(width: geometry.size.width/2.5, height: geometry.size.width/2.5)
                            .clipShape(Circle())
                            .foregroundColor(primaryColor)
                            .padding([.top])
                    } placeholder: {
                        ProgressView()
                            .frame(width: geometry.size.width/2.5, height: geometry.size.width/2.5)
                    }
                } else {
                    Image(systemName: defaultProfile)
                        .resizable()
                        .frame(width: geometry.size.width/2.5, height: geometry.size.width/2.5)
                        .foregroundColor(primaryColor)
                        .padding(.top)
                }
                Button(action: viewModel.sendContacts) { Text("Send Contacts")}
                Button(action: viewModel.refreshCurrentUser) { Text("Refresh User")}
                Text(viewModel.user.displayName())
                    .bold()
                    .padding(.top)
                Text(viewModel.user.username)
                    .padding(.bottom)
                    .foregroundColor(Color(UIColor.darkGray))
                HStack {
                    Text("My Favorites").bold()
                    Spacer()
                }
                AddFriendsButtonView()
                MyFriendsButtonView()
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("My Profile")
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: viewModel.editProfile ) { Text("Edit") }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.tryLogout) { Text("Logout") }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .customNavigation()
        }
    }
}

struct AddProfilePictureView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var image: UIImage
    @State var showingImagePicker: Bool = false
    var body: some View {
        Button(action: { self.showingImagePicker.toggle() }) {
            Text("Add Profile Picture")
                .font(.caption)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(image: $image)
        }
    }
}

struct AddFriendsButtonView: View {
    @EnvironmentObject var viewModel: ViewModel
    var body: some View {
        ModalButtonView(
            title: "Add Favorites",
            buttonContent: {
                HStack {
                    Image(systemName: addFriendsIcon)
                        .frame(width: 10, height: 10)
                        .padding(.trailing)
                    Text("Add Favorites")
                }
            },
            modalContent: { DiscoverFriendsView(favoritees: viewModel.favoritees.filter { !viewModel.favoritesSet.contains($0.id) }, potentials: viewModel.potentials.filter { !viewModel.favoritesSet.contains($0.id) }) })
    }
}

struct MyFriendsButtonView: View {
    @EnvironmentObject var viewModel: ViewModel
    var body: some View {
        ModalButtonView(
            title: "My Favorites",
            buttonContent: {
                HStack {
                    Image(systemName: myFriendsIcon)
                        .frame(width: 10, height: 10)
                        .padding(.trailing)
                    Text("My Favorites")
                }
            },
            modalContent: { MyFriendsView(searchResults: viewModel.favorites) })
    }
}

struct ProfileView_Previews: PreviewProvider {
    static let viewModel: ViewModel = ViewModel()
    static var previews: some View {
        NavigationView {
            ProfileView()
                .background(Color(UIColor.secondarySystemBackground))
        }.environmentObject(viewModel)
    }
}
