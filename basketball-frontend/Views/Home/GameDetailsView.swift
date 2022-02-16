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
    
    @Binding var player: Player
    @Binding var game: Game
    @State var centerLocation: CenterAnnotation = CenterAnnotation(id: 4, subtitle: "Subtitle", title: "Title", latitude: 20.0, longitude: 20.0)
    
    //    @State var showingUsers = false
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
        GeometryReader { geometry in
            List {
                
                // game title
                HStack(alignment: .center) {
                    displayCalendarDate(date: Helper.toDate(date: game.date))
                    Text(game.name)
                        .font(.title)
                        .centeredContent()
                        .lineLimit(1)
                }
                .listRowSeparator(.hidden)
                .padding()
                
                // map centered on the game location by specifying the game focus
                MapView(viewModel: viewModel, games: $viewModel.gameAnnotations, selectedLocation: $viewModel.selectedLocation, moving: .constant(true), gameFocus: $viewModel.game, settingLocation: true)
                    .frame(minWidth: 0, maxWidth: .infinity, idealHeight: geometry.size.height * 0.25)
                    .listRowSeparator(.hidden)
                
                // game details
                VStack {
                    Text("Details")
                        .font(.headline)
                        .leadingText()
                        .padding(.bottom, 1)
                    
                    // date and time
                    HStack {
                        Image(systemName: "clock").imageScale(.small)
                        Text(Helper.getDateTimeProp(dateTime: Helper.toTime(time: game.time), prop: "E, MMM d, h:mm a"))
                        Spacer()
                    }
                    .font(.footnote)
                    .foregroundColor(Color.systemGray)
                    
                    HStack {
                        //        Text(address)
                        Image(systemName: "mappin.and.ellipse").imageScale(.small)
                        Text("5700 Wilkins Avenue, Pittsburgh, PA, 15217")
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
                        Text(game.description)
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
                    PlayerStatusButtonsView(viewModel: viewModel)
                    GameDetailsStatusView()
                }.padding([.top, .bottom], 7)
                Button(action: {}) {
                    Text("Share Game")
                        .font(.subheadline)
                        .foregroundColor(.systemBlue)
                }
                .centeredContent()
                .buttonStyle(BorderlessButtonStyle())
            }
            .listStyle(InsetListStyle())
            .navigationTitle("Game Details")
            .navigationBarTitleDisplayMode(.inline)
            
            
            //    .sheet(isPresented: $sharingGame) { ShareSheetView(activityItems: ["Share this game"]) }
            .onAppear(perform: getAddress)
        }
    }
    
    func getAddress() {
        Helper.coordinatesToPlacemark(latitude: game.latitude, longitude: game.longitude) { placemark in
            self.address = Helper.parseCL(placemark: placemark)
        }
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

enum MyStatus: String, CaseIterable, Identifiable {
    case cannot, maybe, going
    var id: Self { self }
    var color: Color {
        switch self {
        case .cannot:
            return Color.red
        case .maybe:
            return Color.white
        case .going:
            return Color.green
        }
    }
}
struct GameDetailsStatusView: View {
    @State private var selectedStatus: MyStatus = .going
    var body: some View {
        HStack {
            Picker("Status", selection: $selectedStatus) {
                ForEach(MyStatus.allCases) { flavor in
                    Text(flavor.rawValue.capitalized)
                }
            }
            .pickerStyle(.segmented)
            .colorMultiply(selectedStatus.color)
            //            .onChange(of: favoriteColor) { tag in print("Color tag: \(tag)") }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ListButton: View {
    var status: String
    var image: String
    @Binding var users: [Users]
    var showUsers: (String) -> ()
    var body: some View {
        Button(action: { showUsers(status) }) {
            VStack{
                Image(systemName: image)
                    .scaledToFit()
                    .frame(width: 10, height: 10)
                    .padding(.bottom, 2)
                Text("\(users.count) \(status)")
                    .font(.footnote)
                    .lineLimit(1)
            }
        }.buttonStyle(BorderlessButtonStyle())
    }
}

struct PlayerStatusButtonsView: View {
    @ObservedObject var viewModel: ViewModel
    @State var showingUsers: Bool = false
    @State var status: String = "Going"
    @State var users: [Users] = [Users]()
    var body: some View {
        HStack() {
            // button to show list of invited players
            ListButton(status: "Invited", image: "person.fill.xmark", users: $viewModel.invited, showUsers: showForStatus).centeredContent()
            Divider().frame(maxHeight: 40)
            // button to show list of maybe players
            ListButton(status: "Maybe", image: "person.fill.questionmark", users: $viewModel.maybe, showUsers: showForStatus).centeredContent()
            Divider().frame(maxHeight: 40)
            // button to show list of going players
            ListButton(status: "Going", image: "person.fill.checkmark", users: $viewModel.going, showUsers: showForStatus).centeredContent()
        }
        .padding([.top, .bottom])
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )
        .foregroundColor(.black)
        .sheet(isPresented: $showingUsers) {
            PlayersStatusListView(users: $users, status: $status)
        }
    }
    func showForStatus(status: String) -> () {
        self.status = status
        print(status)
        switch status {
        case "Going":
            self.users = viewModel.going
        case "Maybe":
            self.users = viewModel.maybe
        case "Invited":
            self.users = viewModel.invited
        default:
            self.users = viewModel.going
        }
        if self.users.count > 0 { self.showingUsers.toggle() }
    }
}

struct PlayersStatusListView: View {
    @Binding var users: [Users]
    @Binding var status: String
    var body: some View {
        NavigationView {
            UsersListViewDynamic(users: $users)
                .navigationTitle(Text("\(status) Users")).foregroundColor(.black)
                .navigationBarTitleDisplayMode(.inline)
                .customNavigation()
        }
    }
}

struct GameDetailsView_Previews: PreviewProvider {
    static var viewModel = ViewModel()
    static var player: Player = Player(id: 4, status: Status.going)
    static var previews: some View {
        NavigationView {
            GameDetailsView(viewModel: viewModel, player: .constant(player), game: .constant(genericGame))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {}) {
                            Image(systemName: chevronDown)
                        }
                    }
                    ToolbarItem(placement: .principal) { Text("Game Details").foregroundColor(.white) }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .edgesIgnoringSafeArea(.bottom)
                .customNavigation()
        }
    }
}

