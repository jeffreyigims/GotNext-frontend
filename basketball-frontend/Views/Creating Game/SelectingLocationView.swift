//
//  SelectingLocationView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 2/16/22.
//  Copyright © 2022 Matthew Cruz. All rights reserved.
//

import SwiftUI
import MapKit

struct SelectingLocationView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State var moving: Bool = false
    @State var selectedLocation: CLPlacemark?
    @State var mapItem: MKMapItem = MKMapItem()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing){
                StaticMapView(viewModel: viewModel, selectedLocation: $viewModel.selectedLocation, gameFocus: $viewModel.game, settingLocation: false).edgesIgnoringSafeArea(.all)
                MapPinView(geometry: geometry)
            } .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CreateFormView2(location: $viewModel.selectedLocation)) {
                        Text("Select")
                    }.disabled(self.viewModel.selectedLocation.placemark.location == nil)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .customNavigation()
        }
    }
}

struct CreateFormView2: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var location: MKMapItem
    @State var game: Games = Games(id: 4, name: "", date: "", time: "", desc: "", priv: false, longitude: 2.0, latitude: 2.0)
    @State var date: Date = Date()
    @State var address: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("GENERAL")) {
                TextField("Game Title", text: $game.name)
            }
            Section(header: Text("LOCATION")) {
                VStack(alignment: .leading) {
                    Text(location.name ?? "").bold()
                    Text(address)
                }
            }
            Section(header: Text("LOGISTICS")) {
                Toggle(isOn: $game.priv) {
                    Text("Private Game")
                }
                DatePicker("Date", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                TextField("Description", text: $game.desc)
            }
            Section {
                Button(action: {
                    createGame()
                }) {
                    Text("Create Game").centeredContent()
                }
            }
        }
        .navigationBarTitle("Game Details")
        .navigationBarTitleDisplayMode(.inline)
        .customNavigation()
        .onAppear(perform: { self.address = Helper.parseAddress(selectedItem: location.placemark) })
        .alert(isPresented: $viewModel.showAlert) {
            viewModel.alert!
        }
    }
    
    func createGame() {
        viewModel.createGame(name: game.name, date: date, description: game.desc, priv: game.priv, latitude: self.location.placemark.location!.coordinate.latitude, longitude: self.location.placemark.location!.coordinate.longitude, shortAddress: Helper.getShortAddress(placemark: self.location.placemark), longAddress: Helper.parseAddress(selectedItem: self.location.placemark))
    }
}

struct SelectingLocationView_Previews: PreviewProvider {
    static var viewModel: ViewModel = ViewModel()
    static var previews: some View {
        SelectingLocationView().environmentObject(viewModel)
    }
}
