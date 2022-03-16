//
//  StaticMapView.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 2/21/22.
//  Copyright © 2022 Matthew Cruz. All rights reserved.
//

import SwiftUI
import MapKit

struct StaticMapView: UIViewRepresentable {
    @ObservedObject var viewModel: ViewModel
    @Binding var selectedLocation: MKMapItem
    @Binding var gameFocus: Game
    var settingLocation: Bool
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: StaticMapView
        var viewModel: ViewModel
        var selectedLocation: MKMapItem
        
        init (_ parent: StaticMapView) {
            self.parent = parent
            self.viewModel = parent.viewModel
            self.selectedLocation = parent.selectedLocation
        }
        
        func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
            lookUpCenterLocation(coordinates: mapView.centerCoordinate,
                                 completionHandler: { loc in
                if let pl = Helper.CLtoMK(placemark: loc) {
                    self.parent.selectedLocation = MKMapItem(placemark: pl)
                }
            })
        }
        
        // used to change what the annotation view looks like
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
            view.markerTintColor = UIColor(primaryColor)
            view.canShowCallout = true
//            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return view
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            lookUpCenterLocation(coordinates: mapView.centerCoordinate,
                                 completionHandler: { loc in
                if let pl = Helper.CLtoMK(placemark: loc) {
                    self.parent.selectedLocation = MKMapItem(placemark: pl)
                }
            })
            self.parent.settingLocation = false
        }
                
        func lookUpCenterLocation(coordinates: CLLocationCoordinate2D, completionHandler: @escaping (CLPlacemark?) -> Void) {
            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            geocoder.reverseGeocodeLocation(location,
                                            completionHandler: { (placemarks, error) in
                if error == nil {
                    let loc = placemarks?[0]
                    completionHandler(loc)
                }
                else {
                    completionHandler(nil)
                }
            })
        }
    }
    
    func makeCoordinator() -> StaticMapView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        let userLocation = viewModel.userLocation
        userLocation.getCurrentLocation()
        userLocation.loadLocation()
        let coordinate = CLLocationCoordinate2D(
            latitude: userLocation.latitude,
            longitude: userLocation.longitude
        )
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<StaticMapView>) {
        uiView.addAnnotations(viewModel.games)
        if settingLocation {
            let coordinate = CLLocationCoordinate2D(
                latitude: gameFocus.latitude,
                longitude: gameFocus.longitude
            )
            let span = MKCoordinateSpan(latitudeDelta: 0.018, longitudeDelta: 0.018)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            uiView.setRegion(region, animated: true)
        }
    }
}
