//
//  UtiliyViews.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 2/15/22.
//  Copyright © 2022 Matthew Cruz. All rights reserved.
//

import SwiftUI

struct ModalButtonView<ButtonContent: View, ModalContent: View>: View {
    let title: String
    @ViewBuilder var buttonContent: ButtonContent
    @ViewBuilder var modalContent: ModalContent
    @Binding var isPresented: Bool
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
        .buttonStyle(PlainButtonStyle())
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
                .navigationBarColor(UIColor(primaryColor), textColor: .white)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SheetView<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content
    var body: some View {
        NavigationView {
            content
                .navigationTitle(title)
                .navigationBarColor(UIColor(primaryColor), textColor: UIColor(Color.white))
                .navigationBarTitleDisplayMode(.inline)
                .background(Color(UIColor.secondarySystemBackground))
                .edgesIgnoringSafeArea(.bottom)
        }.navigationViewStyle(StackNavigationViewStyle())
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
        ToolbarItem(placement: .principal) { Text(title).foregroundColor(Color.white) }
    }
}

struct GameDetailsModalView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ViewModel
    @State var sharingGame: Bool = false
    
    var body: some View {
        NavigationView {
            GameDetailsView(viewModel: viewModel, sharingGame: $sharingGame, game: $viewModel.game)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: chevronDown)
                        }
                    }
                    ToolbarItem(placement: .principal) { Text("Game Details").foregroundColor(.white) }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { sharingGame.toggle() }) {
                            Image(systemName: shareButton)
                                .imageScale(.medium)
                        }
                    }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .edgesIgnoringSafeArea(.bottom)
                .navigationBarColor(UIColor(primaryColor), textColor: .white)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}


@ViewBuilder func profilePic(profilePic: String?, size: CGFloat) -> some View {
    if let profilePicture: String = profilePic {
        AsyncImage(url: URL(string: profilePicture)) { image in
            image
                .resizable()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } placeholder: {
            ProgressView()
                .frame(width: size, height: size)
        }
    } else {
        Image(systemName: defaultProfileIcon)
            .resizable()
            .frame(width: size, height: size)
            .foregroundColor(.black)
    }
}

