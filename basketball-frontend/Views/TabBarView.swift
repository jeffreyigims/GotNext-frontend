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
    
    var body: some View {
        TabView(selection: $viewModel.currentTab) {
            HomeView(games: $viewModel.userGames)
                .tabItem({ Label("Home", systemImage: homeIcon) }).tag(Tab.home)
            NavigationView {
                ProfileView().background(Color(UIColor.secondarySystemBackground))
            }
            .tabItem({ Label("Profile", systemImage: profileIcon) }).tag(Tab.profile)
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var viewModel: ViewModel = ViewModel()
    static var previews: some View {
        TabBarView().environmentObject(viewModel)
    }
}
