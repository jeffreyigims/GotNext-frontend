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
    @State var pendingRequestWorkItem: DispatchWorkItem?
    
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
                .padding(.top, 10)
            List {
                ForEach(searchResults, id: \.self) { result in
                    NavigationLink(destination: CreateFormView(location: result)) {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .imageScale(.large)
                                .foregroundColor(primaryColor)
                            VStack(alignment: .leading) {
                                Text(result.name ?? "").font(.headline).lineLimit(1)
                                Text(Helper.parseAddress(selectedItem: result.placemark)).font(.subheadline).lineLimit(1)
                            }
                        }
                    }.buttonStyle(PlainButtonStyle())
                }
                NavigationLink(destination: SelectingLocationView()) {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .imageScale(.large)
                            .foregroundColor(primaryColor)
                        Text("Set location on map")
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding([.bottom, .top], 5)
                }
            }
            .padding([.leading, .trailing], 5)
            .listStyle(PlainListStyle())
        }
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    func search() {
        //        let searchRequest = MKLocalSearch.Request()
        //        searchRequest.naturalLanguageQuery = self.locationSearch
        //        let search = MKLocalSearch(request: searchRequest)
        //        if let request = self.searchRequest {
        //            request.cancel()
        //        }
        //        self.searchRequest = search
        //        search.start { response, error in
        //            guard let response = response else {
        //                print("[INFO] error: \(error?.localizedDescription ?? "unknown error")")
        //                return
        //            }
        //            if self.locationSearch == "" {
        //                self.searchResults = []
        //            } else {
        //                self.searchResults = Array<MKMapItem>((response.mapItems.prefix(5)))
        //            }
        //        }
        if self.locationSearch == "" {
            self.searchResults = []
            return
        }
        // cancel the currently pending item
        pendingRequestWorkItem?.cancel()
        
        // wrap our request in a work item
        let requestWorkItem = DispatchWorkItem {
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = self.locationSearch
            let search = MKLocalSearch(request: searchRequest)
            search.start { response, error in
                guard let response = response else {
                    print("[INFO] error: \(error?.localizedDescription ?? "unknown error")")
                    return
                }
                self.searchResults = Array<MKMapItem>((response.mapItems.prefix(5)))
            }
        }
        
        // save the new work item and execute it after 250 ms
        pendingRequestWorkItem = requestWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250), execute: requestWorkItem)
    }
}

struct LocationSearchView_Previews: PreviewProvider {
    static let viewModel: ViewModel = ViewModel()
    static var previews: some View {
        NavigationView {
            LocationSearchView().environmentObject(viewModel)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {}) {
                            Image(systemName: chevronDown)
                        }
                    }
                    ToolbarItem(placement: .principal) { Text("Select Location").foregroundColor(.white) }
                }
                .background(Color(UIColor.secondarySystemBackground))
                .edgesIgnoringSafeArea(.bottom)
                .customNavigation()
        }
    }
}
