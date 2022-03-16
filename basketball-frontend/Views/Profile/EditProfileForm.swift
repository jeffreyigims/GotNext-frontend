//
//  EditProfileForm.swift
//  basketball-frontend
//
//  Created by Jeff Xu on 11/6/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import Foundation
import SwiftUI
import PhotoSelectAndCrop

struct EditProfileForm: View {
    @EnvironmentObject var viewModel: ViewModel
    @State var user: User
    @State var username: String = "mjordan"
    @State var firstName: String = "michael"
    @State var lastName: String = "jordan"
    @State var email: String = "mjordan@gmail.com"
    @State var phone: String = "4123549286"
    @State var image: ImageAttributes
    @State private var isEditMode: Bool = false
    @State private var renderingMode: SymbolRenderingMode = .hierarchical
    
    func setProperties() -> () {
        self.username = viewModel.user.username
        self.firstName = viewModel.user.firstName
        self.lastName = viewModel.user.lastName
        self.email = viewModel.user.email
        self.phone = viewModel.user.phone
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                ImagePane(image: image,
                          isEditMode: .constant(true))
                    .frame(width: geometry.size.width/2, height: geometry.size.width/2)
                    .padding(.top, 35)
                Form {
                    Section(header: Text("PERSONAL")) {
                        TextField("first name", text: $user.firstName)
                        TextField("last name", text: $user.lastName)
                    }
                    Section(header: Text("CONTACT")) {
                        TextField("email", text: $user.email)
                        TextField("phone", text: $user.phone)
                    }
                    Section {
                        Button(action: self.editCurrentUser) {
                            Text("Save Information").foregroundColor(.blue)
                                .centeredContent()
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .onAppear(perform: self.setProperties)
    }
    
    func editCurrentUser() -> () {
        print("[INFO] editing current user")
        self.viewModel.editCurrentUser(user: user, image: self.image.croppedImage)
    }
}

struct EditProfileForm_Previews: PreviewProvider {
    static var viewModel: ViewModel = ViewModel()
    static var previews: some View {
        NavigationView {
            GeometryReader { geometry in
                EditProfileForm(user: genericCurrentUser, image: ImageAttributes(image: viewModel.user.picture, originalImage: nil, croppedImage: nil, scale: 1, xWidth: geometry.size.width/2.5, yHeight: geometry.size.width/2.5)).environmentObject(viewModel)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {}) {
                                Image(systemName: chevronDown)
                            }
                        }
                        ToolbarItem(placement: .principal) { Text("Edit Profile").foregroundColor(.white) }
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .edgesIgnoringSafeArea(.bottom)
                    .navigationBarColor(UIColor(primaryColor), textColor: .white)
            }
        }
    }
}

