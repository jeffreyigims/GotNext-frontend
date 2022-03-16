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
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ViewModel
    @State var invitingFriends: Bool = false
    @Binding var sharingGame: Bool
    @Binding var game: Game
    
    var body: some View {
        GeometryReader { geometry in
            List {
                // game title
                HStack(alignment: .center) {
                    displayCalendarDate(date: game.date)
                        .padding(.trailing)
                    Text(game.name)
                        .font(.title)
                        .centeredContent()
                        .lineLimit(1)
                }
                .listRowSeparator(.hidden)
                .padding()
                
                // map centered on the game location by specifying the game focus
                StaticMapView(viewModel: viewModel, selectedLocation: $viewModel.selectedLocation, gameFocus: $viewModel.game, settingLocation: true)
                    .frame(minWidth: 0, maxWidth: .infinity, idealHeight: geometry.size.height * 0.25)
                    .listRowSeparator(.hidden)
                
                // game details
                VStack {
                    Text("Details")
                        .font(.headline)
                        .leadingText()
                        .padding(.bottom, 1)
                    
                    // date and time
                    HStack(spacing: 0) {
                        Image(systemName: "clock").imageScale(.small)
                        Text(Helper.getDateTimeProp(dateTime: game.date, prop: "  E, MMM d, h:mm a"))
                        Spacer()
                    }
                    .font(.footnote)
                    .foregroundColor(Color.systemGray)
                    
                    HStack(spacing: 0) {
                        Image(systemName: "mappin.and.ellipse").imageScale(.small)
                        Text("  ")
                        Text(game.longAddress)
                        Spacer()
                    }
                    .font(.footnote)
                    .foregroundColor(Color.systemGray)
                }.padding([.top, .bottom], 7)
                
                // game description
                VStack {
                    Text("Description")
                        .font(.headline)
                        .leadingText()
                        .padding(.bottom, 1)
                    
                    HStack {
                        Text(game.desc)
                        Spacer()
                    }
                    .font(.footnote)
                    .foregroundColor(Color.systemGray)
                }.padding([.top, .bottom], 7)
                
                // game status
                VStack {
                    Text("Status")
                        .font(.headline)
                        .leadingText()
                    PlayerStatusButtonsView(viewModel: viewModel, game: $game)
                    GameDetailsStatusView(viewModel: viewModel, game: $game, status: $game.player.status)
                }.padding([.top, .bottom], 7)
                Button(action: inviteFriends) {
                    Text("Invite Friends")
                        .primaryBackground()
                }
                .buttonStyle(PlainButtonStyle())
            }
            .listStyle(InsetListStyle())
            .sheet(isPresented: $invitingFriends) {
                SheetView(title: "Invite Friends") {
                    InvitingUsersView(viewModel: viewModel, game: $game, searchResults: viewModel.user.favorites)
                }
            }
        }
        .sheet(isPresented: $sharingGame) {
            ShareSheetView(activityItems: viewModel.activityItems(game: game))
        }
    }
    
    func inviteFriends() {
        self.invitingFriends.toggle()
    }
}

@ViewBuilder func displayCalendarDate(date: Date) -> some View {
    let monthDay: String = Helper.getDateTimeProp(dateTime: date, prop: "d")
    let month: String = Helper.getDateTimeProp(dateTime: date, prop: "MMM").uppercased()
    VStack {
        Text(monthDay).font(.title2)
        Text(month)
            .font(.footnote)
            .foregroundColor(Color.systemGray)
    }
}

struct GameDetailsStatusView: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var game: Game
    @Binding var status: Status
    var body: some View {
        HStack {
            Picker("Status", selection: $status) {
                ForEach([Status.notGoing, Status.maybe, Status.going]) { status in
                    Text(status.text)
                }
            }
            .pickerStyle(.segmented)
            .colorMultiply(status.color)
            .onChange(of: status) { [status] newStatus in
                print("[INFO] changing status from \(status) to \(newStatus)")
                viewModel.updateStatus(game: game, currStatus: status, newStatus: newStatus)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ListButton: View {
    var status: Status
    var image: String
    @Binding var users: [Users]
    var showUsers: (Status) -> ()
    var body: some View {
        if users.count > 0 {
            Button(action: { showUsers(status) }) {
                VStack{
                    Image(systemName: image)
                        .scaledToFit()
                        .frame(width: 10, height: 10)
                        .padding(.bottom, 2)
                    Text("\(users.count) \(status.toString())")
                        .font(.footnote)
                        .lineLimit(1)
                }
            }.buttonStyle(BorderlessButtonStyle())
        } else {
            VStack{
                Image(systemName: image)
                    .scaledToFit()
                    .frame(width: 10, height: 10)
                    .padding(.bottom, 2)
                Text("\(users.count) \(status.toString())")
                    .font(.footnote)
                    .lineLimit(1)
            }
        }
    }
}

struct PlayerStatusButtonsView: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var game: Game
    @State var showingUsers: Bool = false
    @State var status: Status = Status.going
    @State var users: [Users] = [Users]()
    var body: some View {
        HStack() {
            // button to show list of invited players
            ListButton(status: Status.invited, image: "person.fill.xmark", users: $game.invited, showUsers: showForStatus).centeredContent()
            Divider().frame(maxHeight: 40)
            // button to show list of maybe players
            ListButton(status: Status.maybe, image: "person.fill.questionmark", users: $game.maybe, showUsers: showForStatus).centeredContent()
            Divider().frame(maxHeight: 40)
            // button to show list of going players
            ListButton(status: Status.going, image: "person.fill.checkmark", users: $game.going, showUsers: showForStatus).centeredContent()
        }
        .padding([.top, .bottom])
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )
        .foregroundColor(.black)
        .sheet(isPresented: $showingUsers) {
            SheetView(title: "\(status.toString()) Users") {
                UsersListViewDynamic(users: $users)
            }
        }
    }
    func showForStatus(status: Status) -> () {
        self.status = status
        self.showingUsers.toggle()
        switch status {
        case .going:
            self.users = game.going
        case .maybe:
            self.users = game.maybe
        case .invited:
            self.users = game.invited
        default:
            self.users = game.going
        }
    }
}

struct GameDetailsView_Previews: PreviewProvider {
    static var viewModel = ViewModel()
    static var player: Player = Player(id: 4, status: Status.going)
    static var previews: some View {
        NavigationView {
            GameDetailsView(viewModel: viewModel, sharingGame: .constant(false), game: .constant(genericGame))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {}) {
                            Image(systemName: chevronDown)
                        }
                    }
                    ToolbarItem(placement: .principal) { Text("Game Details").foregroundColor(.white) }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {}) {
                            Image(systemName: shareButton)
                                .imageScale(.medium)
                        }
                    }
                }
                .navigationBarColor(UIColor(primaryColor), textColor: .white)
        }
    }
}

