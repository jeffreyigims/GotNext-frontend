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
  @Binding var games: [GameAnnotation]
//  @Binding var centerLocation: CenterAnnotation
  @Binding var selectedLocation: CLPlacemark?
  @Binding var moving: Bool
  var gameFocus: Game?
  
  class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapView
    var games: [GameAnnotation]
//    var centerLocation: CenterAnnotation
    var selectedLocation: CLPlacemark?
    
    init (_ parent: MapView) {
      self.parent = parent
      self.games = parent.games
//      self.centerLocation = parent.centerLocation
      self.selectedLocation = parent.selectedLocation
    }
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
      lookUpCenterLocation(coordinates: mapView.centerCoordinate,
                           completionHandler: { loc in self.parent.selectedLocation = loc })
      
    }
    
    // Runs every time user interacts and moves map some way
    // Can possibly be used to make pins disappear at certain distance?
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
      self.parent.moving = true
    }
    
    // Used to change what the annotation view looks like
    // Can build a custom view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      if annotation is MKUserLocation {
        return nil
      }
      let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
      view.canShowCallout = true
      view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
      return view
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
      if control == view.rightCalloutAccessoryView {
        parent.viewModel.showDetails()
      }
    }
    
    
    func mapView(_: MKMapView, didSelect view: MKAnnotationView) {
      let currAnnotation = view.annotation as? GameAnnotation
      if let curr = currAnnotation {
        parent.viewModel.getGame(id: Int(curr.id))
        parent.viewModel.findPlayer(gameId: curr.id)  
      }
    }
    
    func mapView(_: MKMapView, didDeselect view: MKAnnotationView) {
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
      lookUpCenterLocation(coordinates: mapView.centerCoordinate,
                           completionHandler: { loc in self.parent.selectedLocation = loc })
      self.parent.moving = false
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
    if let game = gameFocus {
      let coordinate = CLLocationCoordinate2D(
        latitude: game.latitude,
        longitude: game.longitude
      )
      let span = MKCoordinateSpan(latitudeDelta: 0.018, longitudeDelta: 0.018)
      let region = MKCoordinateRegion(center: coordinate, span: span)
      mapView.setRegion(region, animated: true)
    } else {
      let coordinate = CLLocationCoordinate2D(
        latitude: userLocation.latitude,
        longitude: userLocation.longitude
      )
      let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
      let region = MKCoordinateRegion(center: coordinate, span: span)
      mapView.setRegion(region, animated: true)
    }
    mapView.showsUserLocation = true
    print("Make")
    return mapView
  }
  
  func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
    uiView.addAnnotations(viewModel.gameAnnotations)
  }
}

//struct MapView_Previews: PreviewProvider {
//  static var previews: some View {
//    MapView(viewModel: ViewModel(), gameAnnotations: .constant([GameAnnotation]()))
//  }
//}
