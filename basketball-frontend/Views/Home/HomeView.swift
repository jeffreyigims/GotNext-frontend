//
//  HomeView.swift
//  basketball-frontend
//
//  Created by Matthew Cruz on 11/6/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI
import MapKit

struct HomeView: View {
  @EnvironmentObject var viewModel: ViewModel
  @State var isOpen: Bool = false
  @Binding var settingLocation: Bool
  @Binding var selectedLocation: CLPlacemark?
  //  @State var centerLocation: CenterAnnotation = CenterAnnotation(id: 4, subtitle: "Subtitle", title: "Title", latitude: 20.0, longitude: 20.0)
  @State var moving: Bool = false
  var CR: CGFloat = 20
  
  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .topTrailing){
        MapView(viewModel: viewModel, games: $viewModel.gameAnnotations, selectedLocation: $viewModel.selectedLocation, moving: $moving, gameFocus: nil).edgesIgnoringSafeArea(.all)
        if self.settingLocation == true {
          MapPinView(geometry: geometry)
          if self.moving == false {
            VStack {
              Spacer()
              HStack {
                Spacer()
                VStack {
                  Button(action: { viewModel.selectingLocation() }) {
                    Text("Select Location")
                      .padding()
                      .frame(maxWidth: .infinity)
                      .background(Color("primaryButtonColor"))
                      .foregroundColor(.black)
                      .cornerRadius(CR)
                      .padding([.trailing, .leading])
                  }
                  Button(action: { viewModel.cancelSelectingLocation() }) {
                    Text("Cancel")
                      .padding()
                      .frame(maxWidth: .infinity)
                      .background(Color("secondaryButtonColor"))
                      .foregroundColor(.black)
                      .cornerRadius(CR)
                      .padding([.trailing, .leading])
                      .padding(.bottom, 34)
                  }
                }
                Spacer()
              }
            }
          }
        } else {
          VStack {
            NotificationsButtonView(inviteCount: viewModel.getPlayerWithStatus(status: Status.invited).count, tap: tapNotifications)
            CreateGameButtonView(tap: tapCreateGame)
          }.padding()
          // content is passed as a closure to the bottom view
          BottomView(isOpen: self.$isOpen, maxHeight: geometry.size.height * 0.84) {
            GamesTableView()
          }.edgesIgnoringSafeArea(.all)
        }
      }
    }
  }
  
  func tapNotifications() -> () {
    self.viewModel.activeSheet = Sheet.gameInvites
    self.viewModel.showingSheet = true
  }
  func tapCreateGame() -> () {
//    viewModel.startCreating()
    viewModel.refreshCurrentUser()
  }
}

struct HomeView_Previews: PreviewProvider {
  static let viewModel: ViewModel = ViewModel()
  static var previews: some View {
    HomeView(settingLocation: .constant(false), selectedLocation: .constant(nil)).environmentObject(viewModel)
  }
}
