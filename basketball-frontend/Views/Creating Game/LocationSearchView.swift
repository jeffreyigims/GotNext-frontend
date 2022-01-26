//
//  LocationSearchView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 11/19/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI
import MapKit

struct LocationSearchView: View {
  @EnvironmentObject var viewModel: ViewModel
  @State var locationSearch: String = ""
  @State var searchResults: [MKMapItem] = [MKMapItem]()
  
  var body: some View {
    let locSearch = Binding(
      get: { self.locationSearch },
      set: {
        self.locationSearch = $0;
        search()
      }
    )
    VStack {
      SimpleSearchBarView<MKMapItem>(searchText: locSearch)
      List {
        ForEach(searchResults, id: \.self) { result in
          NavigationLink(destination: CreateFormView(location: result)) {
            HStack {
              Image(systemName: "mappin.circle.fill").imageScale(.large).foregroundColor(.red)
              VStack(alignment: .leading) {
                Text(result.name ?? "").font(.headline).lineLimit(1)
                Text(Helper.parseAddress(selectedItem: result.placemark)).font(.subheadline).lineLimit(1)
              }
            }
          }.buttonStyle(PlainButtonStyle())
        }
        Button(action: { viewModel.setLocation() }) {
          HStack {
            Image(systemName: "mappin.circle.fill").imageScale(.large).foregroundColor(.red)
            Text("Set location on map").font(.headline)
            Spacer()
            Image(systemName: chevronRight).imageScale(.small).foregroundColor(Color(UIColor.lightGray)).padding(.trailing, 7)
          }.padding([.bottom, .top], 5)
        }
      }
      .navigationBarTitle("Select Location")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
  
  func search() {
    let searchRequest = MKLocalSearch.Request()
    searchRequest.naturalLanguageQuery = self.locationSearch
    let search = MKLocalSearch(request: searchRequest)
    search.start { response, error in
      guard let response = response else {
        print("Error: \(error?.localizedDescription ?? "Unknown error").")
        return
      }
      if self.locationSearch == "" {
        self.searchResults = []
      } else {
        self.searchResults = Array<MKMapItem>((response.mapItems.prefix(5)))
      }
    }
  }
}

struct LocationSearchView_Previews: PreviewProvider {
  static let viewModel: ViewModel = ViewModel()
  static var previews: some View {
    NavigationView {
      LocationSearchView().environmentObject(viewModel)
    }
  }
}
