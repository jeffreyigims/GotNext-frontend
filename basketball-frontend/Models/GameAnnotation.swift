
import Foundation
import MapKit

class GameAnnotation: NSObject, MKAnnotation {
  
  let id: String
  let subtitle: String?
  let title: String?
  let coordinate: CLLocationCoordinate2D
  
  init(id: Int, subtitle: String, title: String, latitude: Double, longitude: Double) {
    self.id = String(id)
    self.subtitle = subtitle
    self.title = title
    self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}

class CenterAnnotation: NSObject, MKAnnotation {
  
  let subtitle: String?
  let title: String?
  var coordinate: CLLocationCoordinate2D
  
  init(id: Int, subtitle: String, title: String, latitude: Double, longitude: Double) {
    self.subtitle = subtitle
    self.title = title
    self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}
