//
//  LandingView.swift
//  basketball-frontend
//
//  Created by Jeff Xu on 12/1/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import Foundation
import SwiftUI
import AuthenticationServices

struct LandingView: View {
    @EnvironmentObject var viewModel: ViewModel
    var CR: CGFloat = 8
    @State private var selection: String? = nil
    @State private var token: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image("logo")
                    .colorMultiply(primaryColor)
                Text("GotNext")
                    .font(.largeTitle)
                    .foregroundColor(primaryColor)
                Spacer()
                TextField("token", text: $token)
                Button(action: { viewModel.saveToken(token: token, id: 1) }) {
                    Text("Save Token")
                }
                NavigationLink(destination: AdditionalInformationView(), tag: "additionalInformation", selection: $viewModel.landingLink) { EmptyView() }
                
                //                NavigationLink(destination: LoginView(), tag: "login", selection: $selection) { EmptyView() }
                //                Button(action: { selection = "login" }){
                //                    Text("Log In")
                //                        .font(.title3)
                //                        .bold()
                //                        .frame(maxWidth: .infinity, minHeight: 57)
                //                    //            .background(Color("primaryButtonColor"))
                //                        .background(primaryColor)
                //                        .foregroundColor(.white)
                //                        .cornerRadius(CR)
                //                        .padding([.trailing, .leading])
                //                }
                //                .buttonStyle(PlainButtonStyle())
                
                //                NavigationLink(destination: CreateUserView(), tag: "create", selection: $selection) { EmptyView() }
                //                Button(action: { selection = "create" }){
                //                    Text("Create Account")
                //                    //                        .font(.system(size: 57 * 0.43))
                //                        .font(.title3)
                //                        .bold()
                //                        .frame(maxWidth: .infinity, minHeight: 57)
                //                    //            .background(Color("secondaryButtonColor"))
                //                        .background(primaryColor)
                //                        .foregroundColor(.white)
                //                        .cornerRadius(CR)
                //                        .padding([.trailing, .leading])
                //                }
                //                .buttonStyle(PlainButtonStyle())
                //                .padding(.top, 24)
                
                // https://blog.xmartlabs.com/blog/sign-in-with-apple-with-swiftui/
                SignInWithAppleButton(.continue) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    viewModel.handleAuthorization(result: result)
                }
                .signInWithAppleButtonStyle(.black)
                .padding()
                .padding([.trailing, .leading])
                .frame(maxHeight: 95)
            }
            .hideNavigationBar()
        }
    }
}

struct LandingView_Previews: PreviewProvider {
    static let viewModel: ViewModel = ViewModel()
    static var previews: some View {
        LandingView().environmentObject(viewModel)
    }
}
