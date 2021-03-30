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
  @State var locationSearch: String = ""
  @State var searchResults: [MKMapItem] = [MKMapItem]()
  @ObservedObject var viewModel: ViewModel
  
  var body: some View {
    let locSearch = Binding(
      get: { self.locationSearch },
      set: {
        self.locationSearch = $0;
        search()
      }
    )
    NavigationView {
      VStack {
        SearchBarView<MKMapItem>(searchText: locSearch)
        List {
          ForEach(searchResults, id: \.self) { result in
            NavigationLink(destination: CreateFormView(viewModel: viewModel, location: result)) {
              HStack {
                Image(systemName: "mappin.circle.fill").font(Font.system(.largeTitle))
                VStack(alignment: .leading) {
                  Text(result.name ?? "").bold()
                  Text(Helper.parseAddress(selectedItem: result.placemark))
                }
              }
            }.buttonStyle(PlainButtonStyle())
          }
          Button(action: { viewModel.setLocation() }) {
            HStack {
              Image(systemName: "mappin.circle.fill").font(Font.system(.largeTitle))
              Text("Set location on map")
            }
          }
        }
      }.navigationBarTitle("Select Location")
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
      self.searchResults = Array<MKMapItem>((response.mapItems.prefix(5)))
    }
  }
}

struct LocationSearchView_Previews: PreviewProvider {
  static var previews: some View {
    LocationSearchView(viewModel: ViewModel())
  }
}
