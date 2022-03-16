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
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                viewModel.user.picture
                    .resizable()
                    .frame(width: geometry.size.width/2.5, height: geometry.size.width/2.5)
                    .clipShape(Circle())
                    .padding([.top])
                Button(action: viewModel.fetchContacts) { Text("Fetch Contacts")}
//                Button(action: viewModel.sendContacts) { Text("Send Contacts")}
                Button(action: viewModel.refreshCurrentUser) { Text("Refresh User")}
//                Button(action: viewModel.createDevice) { Text("Send Token")}
//                Button(action: viewModel.saveToken) { Text("Save Token")}
//                Button(action: viewModel.loadToken) { Text("Load Token")}
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
            .onAppear(perform: viewModel.requestContactAccess)
            .fullScreenCover(isPresented: $viewModel.editingProfile) {
                ModalView(title: viewModel.user.username) {
                    EditProfileForm(user: viewModel.user, image: ImageAttributes(image: viewModel.user.picture, originalImage: nil, croppedImage: nil, scale: 1, xWidth: geometry.size.width/2.5, yHeight: geometry.size.width/2.5)).alert(isPresented: $viewModel.showAlert) { viewModel.alert! }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("My Profile")
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { viewModel.editingProfile.toggle() }) { Text("Edit") }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.tryLogout) { Text("Logout") }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarColor(UIColor(primaryColor), textColor: .white)
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
            modalContent: { DiscoverFriendsView(favoritees: viewModel.favoriteesNotFavorited, potentials: viewModel.potentials, searchResults: $viewModel.searchResults, contacts: viewModel.contactPotentials) }, isPresented: $viewModel.showingDiscoverFavorites)
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
            modalContent: { MyFriendsView(searchResults: viewModel.user.favorites) }, isPresented: $viewModel.showingMyFavorites)
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
