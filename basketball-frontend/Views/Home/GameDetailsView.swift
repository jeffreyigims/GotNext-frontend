//
//  GameDetailsView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 11/9/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI
import MapKit

struct GameDetailsView: View {
  // must be observable
  @ObservedObject var viewModel: ViewModel
  
  @Binding var player: Player?
  @Binding var game: Game
  @State var centerLocation: CenterAnnotation = CenterAnnotation(id: 4, subtitle: "Subtitle", title: "Title", latitude: 20.0, longitude: 20.0)
  
  @State var showingUsers = false
  @State var sharingGame = false
  @State var usersStatus: String = "Going"
  @State var selectedStatusList: String = "Going"
  @State var invitingUsers = false
  @State var showingActionSheet = false
  @State var users: [Users] = [Users]()
  @State private var selectedStatus = 0
  @State var address: String = ""
  
  var CR: CGFloat = 18
  
  var body: some View {
    NavigationView {
      GeometryReader { geometry in
        VStack {
          
          // game name
          Text(game.name)
            .font(.largeTitle)
            .leadingText()
          
          // date and time
          HStack {
            Text(game.onDate())
            Spacer()
            Image(systemName: "clock").imageScale(.small)
            Text(game.onTime())
          }
          
          // map centered on the game location by specifying the game focus
          MapView(viewModel: viewModel, games: $viewModel.gameAnnotations, selectedLocation: $viewModel.selectedLocation, moving: .constant(true), gameFocus: self.game)
            .edgesIgnoringSafeArea(.all)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: geometry.size.height * 0.30)
          
          //        Text(address)
          Text("5700 Wilkins Avenue, Pittsburgh, PA, 15217")
            .trailingText()
            .font(.caption)
            .padding([.leading,.bottom])
          
          Button(action: { self.viewModel.shareGame() }) {
            Text("Share Game")
          }
          
          Divider()
          PlayerStatusButtonsView(viewModel: viewModel)
          
          // game status
          Button(action: { showingActionSheet = true }) {
            HStack{
              Text(player?.status.toString() ?? "Not Going")
              Image(systemName: "chevron.down")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("secondaryButtonColor"))
            .foregroundColor(.black)
            .cornerRadius(CR)
          }
          
          // invite users
          NavigationLink(destination: InvitingUsersView()) {
            Text("Invite Friends")
              .padding()
              .frame(maxWidth: .infinity)
              .background(Color("secondaryButtonColor"))
              .foregroundColor(.black)
              .cornerRadius(CR)
          }
          
          // game description
          VStack(alignment: .leading){
            Text("Game Notes:")
              .font(.system(size: 20))
            Text(game.description)
              .padding()
              .frame(maxWidth: .infinity)
              .background(Color("secondaryButtonColor"))
              .foregroundColor(.black)
              .cornerRadius(CR)
          }
        }
      }
      .navigationTitle("Game Details")
      .navigationBarTitleDisplayMode(.inline)
      
      //    .sheet(isPresented: $showingUsers) {
      //      UsersStatusView(users: $users, status: selectedStatusList)
      //    }
      //    .actionSheet(isPresented: $showingActionSheet) {
      //      ActionSheet(title: Text("Change Status"), message: Text("Select a status"), buttons: [
      //
      //        .default(Text("Maybe")) { statusChange(selectedStatus: "I'm Maybe") },
      //        .default(Text("Going")) { statusChange(selectedStatus: "I'm Going") },
      //        .default(Text("Not Going")) { statusChange(selectedStatus: "I'm Not Going") },
      //        .cancel()
      //      ])
      //    }
      //    .alert(isPresented: $viewModel.showAlert) {
      //      viewModel.alert!
      //    }
      //    .sheet(isPresented: $sharingGame) { ShareSheetView(activityItems: ["Share this game"]) }
    }
    .onAppear(perform: getAddress)
  }
  
  // helper methods
  func statusChange(selectedStatus: String) {
    if let p = self.player {
      viewModel.editPlayerStatus(playerId: p.id, status: selectedStatus)
    } else {
      viewModel.createPlayer(status: selectedStatus, userId: viewModel.userId!, gameId: self.game.id)
    }
  }
  
  func assignUsers(users: [Users], status: String) {
    self.users = users
    self.showingUsers = true
    self.selectedStatusList = status
  }
  
  func getAddress() {
    Helper.coordinatesToPlacemark(latitude: game.latitude, longitude: game.longitude) { placemark in
      self.address = Helper.parseCL(placemark: placemark)
    }
  }
}

//MARK: - Player List Button Struct
struct PlayerListButton: View {
  var selectedUsers: [Users]
  var status: String
  var image: String
  @Binding var users: [Users]
  @Binding var showingUsers: Bool
  @Binding var selectedStatusList: String
  var CR: CGFloat = 20
  var body: some View{
    // Button to view going players
    Button(action: { assignUsers(users: selectedUsers, status: status)}){
      VStack{
        Image(systemName: image)
          .font(.system(size: 20))
          .frame(width: 22, height: 20)
          .padding(.bottom, 2)
        Text("\(selectedUsers.count) \(status)")
      }
      // Vstack modifiers
      .padding([.bottom, .top], 10)
      .padding([.leading, .trailing], 20)
      .background(Color("primaryButtonColor"))
      .foregroundColor(.black)
      .cornerRadius(CR)
    }
    // Button modifiers
    .frame(maxWidth: .infinity)
  }
  func assignUsers(users: [Users], status: String) {
    self.users = users
    if (users.count > 0) {
      self.showingUsers = true
      self.selectedStatusList = status
    }
  }
}

//MARK: - Extensions
extension Binding {
  func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
    return Binding(
      get: { self.wrappedValue },
      set: { selection in
        self.wrappedValue = selection
        handler(selection)
      })
  }
}

struct GameDetailsView_Previews: PreviewProvider {
  static var viewModel = ViewModel()
  static var game = Game(id: 1, name: "CMU Game", date: "2021-05-15", time: "2000-01-01T22:57:58.075Z", description: "", priv: true, longitude: -79.94456661125692, latitude: 40.441405662286684, invited: [APIData<Users>](), maybe: [APIData<Users>](), going: [APIData<Users>]())
  static var previews: some View {
    NavigationView {
      GameDetailsView(viewModel: viewModel, player: .constant(nil), game: .constant(game))
        .background(Color(UIColor.secondarySystemBackground))
        .edgesIgnoringSafeArea(.bottom)
    }
  }
}

struct ListButton: View {
  var status: String
  var image: String
  @Binding var users: [Users]
  @State var showingUsers: Bool = false
  var body: some View {
    Button(action: { showingUsers.toggle() }) {
      VStack{
        Image(systemName: image)
          .imageScale(.medium)
          .padding(.bottom, 2)
        Text("\(users.count) \(status)")
      }
      .padding([.leading, .trailing])
    }
    .sheet(isPresented: $showingUsers) {
      NavigationView {
        UsersListViewDynamic(users: $users)
          .padding([.leading, .trailing])
          .navigationTitle("\(status) Users")
          .navigationBarTitleDisplayMode(.inline)
      }
    }
  }
}

struct PlayerStatusButtonsView: View {
  @ObservedObject var viewModel: ViewModel
  var body: some View {
    HStack() {
      // button to show list of going players
      ListButton(status: "Going", image: "checkmark", users: $viewModel.going).centeredContent()
      Divider().frame(maxHeight: 45)
      // button to show list of maybe players
      ListButton(status: "Maybe", image: "questionmark.diamond", users: $viewModel.maybe).centeredContent()
      Divider().frame(maxHeight: 45)
      // button to show list of invited players
      ListButton(status: "Invited", image: "envelope", users: $viewModel.invited).centeredContent()
    }
    .padding()
    .frame(maxWidth: .infinity)
    .background(Color(.white))
    .foregroundColor(.black)
    .cornerRadius(18)
  }
}

