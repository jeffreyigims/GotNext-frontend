//
//  MapView.swift
//  FindMyCar
//
//  Created by Matthew Cruz on 10/11/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var viewModel: ViewModel
    @Binding var selectedLocation: MKMapItem
    @Binding var gameFocus: Game
    @Binding var settingLocation: Bool
    @State var reFocus: Bool = false
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        var viewModel: ViewModel
        
        init (_ parent: MapView) {
            self.parent = parent
            self.viewModel = parent.viewModel
        }
        
        func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
            lookUpCenterLocation(coordinates: mapView.centerCoordinate,
                                 completionHandler: { loc in
                if let pl = Helper.CLtoMK(placemark: loc) {
                    self.parent.selectedLocation = MKMapItem(placemark: pl)
                }
            })
        }
        
        // runs every time user interacts and moves map some way
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        }
        
        // used to change what the annotation view looks like
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
            view.markerTintColor = UIColor(primaryColor)
            view.canShowCallout = true
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return view
        }
        
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if control == view.rightCalloutAccessoryView {
                if let game = view.annotation as? Game {
                    self.parent.viewModel.showGame(game: game)
                }
            }
        }
        
        
        func mapView(_: MKMapView, didSelect view: MKAnnotationView) {
            let currAnnotation = view.annotation as? Game
            if let curr = currAnnotation {
                parent.viewModel.getGame(id: curr.id)
            }
        }
        
        func mapView(_: MKMapView, didDeselect view: MKAnnotationView) {
            parent.settingLocation = false
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
    
    func makeCoordinator() -> MapView.Coordinator {
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
    
    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        uiView.addAnnotations(viewModel.games)
        if settingLocation {
            let coordinate = CLLocationCoordinate2D(
                latitude: viewModel.game.latitude,
                longitude: viewModel.game.longitude
            )
            let span = MKCoordinateSpan(latitudeDelta: 0.018, longitudeDelta: 0.018)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            uiView.setRegion(region, animated: true)
            let gameFocusAnnotation: MKAnnotation? = uiView.annotations.filter { annotation in
                let currAnnotation = annotation as? Game
                if let curr = currAnnotation {
                    return curr.id == viewModel.game.id
                }
                return false
            }.first
            if let gameFocusAnnotation: MKAnnotation = gameFocusAnnotation {
                uiView.selectAnnotation(gameFocusAnnotation, animated: true)
            }
        }
        if viewModel.reFocusUser {
            let userLocation = viewModel.userLocation
            userLocation.getCurrentLocation()
            userLocation.loadLocation()
            let coordinate = CLLocationCoordinate2D(
                latitude: userLocation.latitude,
                longitude: userLocation.longitude
            )
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            uiView.setRegion(region, animated: true)
            uiView.showsUserLocation = true
            viewModel.reFocusUser = false
        }
    }
}
