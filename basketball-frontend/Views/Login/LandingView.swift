//
//  LandingView.swift
//  basketball-frontend
//
//  Created by Jeff Xu on 12/1/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import Foundation
import SwiftUI

struct LandingView: View {
  @EnvironmentObject var viewModel: ViewModel
  var CR: CGFloat = 20
  
  var body: some View {
    NavigationView {
      VStack {
        Spacer()
        Image("logo")
        Text("GotNext")
          .font(.largeTitle)
          .foregroundColor(Color("tabBarColor"))
        Spacer()
        NavigationLink(destination: LoginView()) {
          Text("Log In")
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("primaryButtonColor"))
            .foregroundColor(.black)
            .cornerRadius(CR)
            .padding([.trailing, .leading])
        }
        
        NavigationLink(destination: CreateUserView()) {
          Text("Create Account")
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("secondaryButtonColor"))
            .foregroundColor(.black)
            .cornerRadius(CR)
            .padding([.trailing, .leading])
        }
      }
    }
  }
}

struct LandingView_Previews: PreviewProvider {
  static let viewModel: ViewModel = ViewModel()
  static var previews: some View {
    LandingView().environmentObject(viewModel)
  }
}
