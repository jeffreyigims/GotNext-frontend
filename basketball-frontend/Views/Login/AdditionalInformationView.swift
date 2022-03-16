//
//  AdditionalInformationView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 3/14/22.
//  Copyright © 2022 Matthew Cruz. All rights reserved.
//

import SwiftUI

struct AdditionalInformationView: View {
    @EnvironmentObject var viewModel: ViewModel
    
    var body: some View {
        Form {
            Section(header: Text("GENERAL")) {
                TextField("First Name", text: $viewModel.potentialUser.givenName)
                    .disableAutocorrection(true)
                TextField("Last Name", text: $viewModel.potentialUser.familyName)
                    .disableAutocorrection(true)
                TextField("Email", text: $viewModel.potentialUser.email)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            Section(header: Text("ADDITIONAL")) {
                DatePicker("Date of Birth", selection: $viewModel.potentialUser.dob, in: ...Date(), displayedComponents: [.date])
                TextField("Phone", text: $viewModel.potentialUser.phone)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            Section {
                Button(action: createUser) {
                    Text("Sign Up").foregroundColor(.blue)
                }.buttonStyle(DefaultButtonStyle())
            }
        }
        .navigationBarTitle("Sign Up")
        .navigationBarTitleDisplayMode(.inline)
        .customNavigation()
    }
    
    func createUser() -> () {
        viewModel.createPotentialUser(potentialUser: viewModel.potentialUser)  
    }
}

struct AdditionalInformationView_Previews: PreviewProvider {
    static let viewModel: ViewModel = ViewModel()
    static var previews: some View {
        AdditionalInformationView().environmentObject(viewModel)
    }
}
