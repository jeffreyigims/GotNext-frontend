//
//  TabBarView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 12/13/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI
import MapKit

struct TabBarView: View {
    @EnvironmentObject var viewModel: ViewModel
    @Binding var settingLocation: Bool
    @Binding var selectedLocation: CLPlacemark?
    @State var moving: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            if self.settingLocation == true {
                ZStack(alignment: .topTrailing){
                    MapView(viewModel: viewModel, games: $viewModel.gameAnnotations, selectedLocation: $viewModel.selectedLocation, moving: $moving, gameFocus: $viewModel.game, settingLocation: false).edgesIgnoringSafeArea(.all)
                    MapPinView(geometry: geometry)
                    if self.moving == false {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                VStack {
                                    SelectLocationButtonView(tapAction: viewModel.selectingLocation)
                                    CancelSelectLocationButtonView(tapAction: viewModel.cancelSelectingLocation)
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
            else {
                TabView {
                    HomeView(games: $viewModel.userGames)
                        .tabItem({ Label("Home", systemImage: homeIcon) }).tag(0)
                    NavigationView {
                        ProfileView().background(Color(UIColor.secondarySystemBackground))
                    }
                    .tabItem({ Label("Profile", systemImage: profileIcon) }).tag(1)
                }
            }
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var viewModel: ViewModel = ViewModel()
    static var previews: some View {
        TabBarView(settingLocation: .constant(false), selectedLocation: .constant(nil)).environmentObject(viewModel)
    }
}
