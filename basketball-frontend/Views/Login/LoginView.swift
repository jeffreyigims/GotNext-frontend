//
//  LoginView.swift
//  basketball-frontend
//
//  Created by Jeff Xu on 12/1/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import Foundation
import SwiftUI

struct LoginView: View {
  @EnvironmentObject var viewModel: ViewModel
  @State var username: String = ""
  @State var password: String = ""
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField("Username", text: $username)
            .autocapitalization(.none)
            .disableAutocorrection(true)
          SecureField("Password", text: $password)
            .autocapitalization(.none)
            .disableAutocorrection(true)
        }
        Button(action: {
          login()
        }) {
          Text("Login")
        }
      }.navigationBarTitle("Login")
      .alert(isPresented: $viewModel.showAlert) {
        viewModel.alert!
      }
    }
  }
  
  func login() {
    viewModel.login(username: username, password: password)
  }
}

struct LoginView_Previews: PreviewProvider {
  static let viewModel: ViewModel = ViewModel()
  static var previews: some View {
    LoginView().environmentObject(viewModel)
  }
}
