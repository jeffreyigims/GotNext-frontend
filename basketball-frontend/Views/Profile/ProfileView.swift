//
//  ProfileView.swift
//  basketball-frontend
//
//  Created by Matthew Cruz on 11/6/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI

struct ProfileView: View {
  @EnvironmentObject var viewModel: ViewModel
  @State var editingProfile = false
  @State var image: UIImage = UIImage()
  
  var body: some View {
    GeometryReader { geometry in
      VStack {
        //        Image(systemName: "person.crop.circle")
        Image(uiImage: self.image)
          .resizable()
          .frame(width: geometry.size.width/2.5, height: geometry.size.width/2.5)
          .scaledToFit()
          .clipShape(Circle())
          .overlay(
            Circle()
              .stroke(Color.white, lineWidth: 4)
              .shadow(radius: 10)
          )
        AddProfilePictureView(image: $image)
        Text(viewModel.user?.displayName() ?? "Michael Jordan")
          .bold()
          .padding(.top)
        Text(viewModel.user?.username ?? "mjordan")
          .padding(.bottom)
          .foregroundColor(Color(UIColor.darkGray))
        HStack {
          Text("My Favorites").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
          Spacer()
        }
        AddFriendsButtonView()
        MyFriendsButtonView()
      }
      .padding()
      .toolbar {
        ToolbarItem(placement: .principal) { Text("My Profile") }
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: viewModel.editProfile ) { Text("Edit") }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: viewModel.tryLogout) { Text("Logout") }
        }
      }
      .navigationBarTitleDisplayMode(.inline)
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
      modalContent: { DiscoverFriendsView() })
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

struct ModalButtonView<ButtonContent: View, ModalContent: View>: View {
  let title: String
  @ViewBuilder var buttonContent: ButtonContent
  @ViewBuilder var modalContent: ModalContent
  @State private var isPresented: Bool = false
  var body: some View {
    Button(action: { isPresented.toggle() }) {
      HStack {
        buttonContent
        Spacer()
        Image(systemName: chevronRight)
      }
      .padding()
      .frame(maxWidth: .infinity)
      .background(Color.white)
      .foregroundColor(.black)
      .cornerRadius(12)
    }
    .fullScreenCover(isPresented: $isPresented) {
      ModalView(title: title) {
        modalContent
      }
    }
  }
}

struct ModalView<Content: View>: View {
  @Environment(\.presentationMode) var presentationMode
  let title: String
  @ViewBuilder var content: Content
  var body: some View {
    NavigationView {
      content
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ModalToolbar(presentationMode: presentationMode, title: title) }
        .background(Color(UIColor.secondarySystemBackground))
        .edgesIgnoringSafeArea(.bottom)
    }
  }
}

struct ModalToolbar: ToolbarContent {
  @Binding var presentationMode: PresentationMode
  let title: String
  var body: some ToolbarContent {
    ToolbarItem(placement: .navigationBarLeading) {
      Button(action: { $presentationMode.wrappedValue.dismiss() }) {
        Image(systemName: chevronDown)
      }
    }
    ToolbarItem(placement: .principal) { Text(title) }
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
