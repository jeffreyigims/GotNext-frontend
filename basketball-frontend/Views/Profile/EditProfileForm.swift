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
    @State var username: String = "mjordan"
    @State var firstName: String = "michael"
    @State var lastName: String = "jordan"
    @State var email: String = "mjordan@gmail.com"
    @State var phone: String = "4123549286"
    @State private var image: ImageAttributes = ImageAttributes(withSFSymbol: defaultProfile)
    @State private var isEditMode: Bool = false
    @State private var renderingMode: SymbolRenderingMode = .hierarchical
    
    func setProperties() -> () {
        //        self.username = viewModel.user?.username ?? "mjordan"
        //        self.firstName = viewModel.user?.firstName ?? "michael"
        //        self.lastName = viewModel.user?.lastName ?? "jordan"
        //        self.email = viewModel.user?.email ?? "mjordan@gmail.com"
        //        self.phone = viewModel.user?.phone ?? "4123549286"
        self.username = viewModel.user.username
        self.firstName = viewModel.user.firstName
        self.lastName = viewModel.user.lastName
        self.email = viewModel.user.email
        self.phone = viewModel.user.phone
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                //        Image(systemName: "person.crop.circle")
                //          .resizable()
                //          .frame(width: geometry.size.width/2.5, height: geometry.size.width/2.5)
                //          .scaledToFit()
                //          .clipShape(Circle())
                //          .overlay(
                //            Circle()
                //              .stroke(Color.white, lineWidth: 4)
                //              .shadow(radius: 10)
                //          )
                ImagePane(image: image,
                          isEditMode: .constant(true),
                          renderingMode: renderingMode)
//                    .resizable()
                    .frame(width: geometry.size.width/2.5, height: geometry.size.width/2.5)
                    .foregroundColor(primaryColor)
//                    .padding(.top)
                Form {
                    Section(header: Text("PERSONAL")) {
                        TextField("first name", text: $firstName)
                        TextField("last name", text: self.$lastName)
                    }
                    Section(header: Text("CONTACT")) {
                        TextField("email", text: self.$email)
                        TextField("phone", text: self.$phone)
                    }
                    Section {
                        Button(action: self.editCurrentUser) {
                            Text("Save Information").centeredContent()
                        }
                    }
                }
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .onAppear(perform: self.setProperties)
    }
    
    func editCurrentUser() -> () {
        print("[INFO] editing current user")
        self.viewModel.editCurrentUser(firstName: self.firstName, lastName: self.lastName, username: self.username, email: self.email, phone: self.phone, image: self.image.croppedImage)
    }
}

struct EditProfileForm_Previews: PreviewProvider {
    static var viewModel: ViewModel = ViewModel()
    static var previews: some View {
        NavigationView {
            EditProfileForm().environmentObject(viewModel)
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
                .customNavigation()
        }
    }
}

