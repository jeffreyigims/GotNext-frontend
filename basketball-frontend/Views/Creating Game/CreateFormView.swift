//
//  CreateFormView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 11/10/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI
import MapKit

struct CreateFormView: View {
    @EnvironmentObject var viewModel: ViewModel
    let location: MKMapItem
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
                Button(action: createGame) {
                    Text("Create Game").centeredContent()
                }.buttonStyle(PlainButtonStyle())
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

struct CreateFormView_Previews: PreviewProvider {
    static let viewModel: ViewModel = ViewModel()
    static var previews: some View {
        NavigationView {
            CreateFormView(location: MKMapItem()).environmentObject(viewModel)
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
