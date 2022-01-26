//
//  EditProfileForm.swift
//  basketball-frontend
//
//  Created by Jeff Xu on 11/6/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import Foundation
import SwiftUI

struct EditProfileForm: View {
  @EnvironmentObject var viewModel: ViewModel
  @State var username: String = "mjordan"
  @State var firstName: String = "michael"
  @State var lastName: String = "jordan"
  @State var email: String = "mjordan@gmail.com"
  @State var phone: String = "4123549286"
  
  func setProperties() -> () {
    self.username = viewModel.user?.username ?? "mjordan"
    self.firstName = viewModel.user?.firstName ?? "michael"
    self.lastName = viewModel.user?.lastName ?? "jordan"
    self.email = viewModel.user?.email ?? "mjordan@gmail.com"
    self.phone = viewModel.user?.phone ?? "4123549286"
  }
  
  var body: some View {
    GeometryReader { geometry in
      VStack {
        Image(systemName: "person.crop.circle")
          .resizable()
          .frame(width: geometry.size.width/2.5, height: geometry.size.width/2.5)
          .scaledToFit()
          .clipShape(Circle())
          .overlay(
            Circle()
              .stroke(Color.white, lineWidth: 4)
              .shadow(radius: 10)
          )
        Text(self.username).foregroundColor(Color(UIColor.darkGray))
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
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text("My Profile")
      }
    }
    .background(Color(UIColor.secondarySystemBackground))
    .onAppear(perform: self.setProperties)
  }
  
  func editCurrentUser() -> () {
    self.viewModel.editCurrentUser(firstName: self.firstName, lastName: self.lastName, username: self.username, email: self.email, phone: self.phone)
  }
}

struct EditProfileForm_Previews: PreviewProvider {
  //  static let user: User = User(id: 4, username: "mjordan", email: "mjordan@gmail.com", firstName: "Michael", lastName: "Jordan", dob: "12/10/1999", phone: "4123549286", players: [APIData<Player>](), favorites: [APIData<Favorite>](), potentials: [APIData<Users>](), contacts: [APIData<Contact>]())
  static var viewModel: ViewModel = ViewModel()
  static var previews: some View {
    NavigationView {
      EditProfileForm()
    }.environmentObject(viewModel)
  }
}

