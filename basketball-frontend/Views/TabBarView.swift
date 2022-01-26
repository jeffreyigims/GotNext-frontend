//
//  TabBarView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 12/13/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI

struct TabBarOldView: View {
  @EnvironmentObject var viewModel: ViewModel
  var geometry: GeometryProxy
  
  var body: some View {
    HStack{
      // home Icon
      Image(systemName: "house")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundColor(Color("tabBarIconColor"))
        .padding(20)
        .frame(width: geometry.size.width/3, height: 75)
        .foregroundColor(Color("tabBarIconColor"))
        .onTapGesture {
          viewModel.currentTab = Tab.home
        }
      
      ZStack{
        // plus Icon
        Circle()
          .foregroundColor(Color("tabBarColor"))
          .frame(width:75, height:75)
          .offset(y: -geometry.size.height/10/2)
        
        Image(systemName: "plus.circle.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 75, height: 75)
          .foregroundColor(Color("tabBarIconColor"))
          .offset(y: -geometry.size.height/10/2)
          .onTapGesture {
            viewModel.startCreating()
          }
      }
      // profile Icon
      Image(systemName: "person")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundColor(Color("tabBarIconColor"))
        .padding(20)
        .frame(width: geometry.size.width/3, height: 75)
        .onTapGesture{
          viewModel.currentTab = Tab.profile
        }
    }
    .frame(width: geometry.size.width, height: geometry.size.height/10)
    .background(Color("tabBarColor").shadow(radius: 5))
  }
}

struct TabBarView: View {
  @EnvironmentObject var viewModel: ViewModel
  
  var body: some View {
    TabView {
      HomeView(settingLocation: $viewModel.settingLocation, selectedLocation: $viewModel.selectedLocation)
        .tabItem({ Label("Home", systemImage: homeIcon) }).tag(0)
      NavigationView {
        ProfileView().background(Color(UIColor.secondarySystemBackground))
      }
      .tabItem({ Label("Profile", systemImage: profileIcon) }).tag(1)
    }
  }
}

struct TabBarView_Previews: PreviewProvider {
  static var viewModel: ViewModel = ViewModel()
  static var previews: some View {
    TabBarView().environmentObject(viewModel)
  }
}
