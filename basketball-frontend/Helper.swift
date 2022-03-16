//
//  Helper.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 11/9/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import Foundation
import MapKit

class Helper {
    
    static func toDate(timeString: String, dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        let time: String = matchRegex(input: timeString, regex: "T(.*)Z")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-ddHH:mm:ss.SSS"
        let formattedDate = dateFormatter.date(from: dateString+time)
        if let date: Date = formattedDate {
            return date
        } else {
            print("[INFO] could not convert date \(dateString) and time \(timeString) to date")
            return Date()
        }
    }
    
    static func getDateTimeProp(dateTime: Date, prop: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = prop
        formatter.calendar = NSCalendar.current
        formatter.timeZone = TimeZone.current
        let prop = formatter.string(from: dateTime)
        return prop
    }
    
    static func matchRegex(input: String, regex: String) -> String {
        do {
            let regex = try NSRegularExpression(pattern: regex, options: NSRegularExpression.Options.caseInsensitive)
            let matches = regex.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))
            
            if let match = matches.first {
                let range = match.range(at:1)
                if let swiftRange = Range(range, in: input) {
                    let ouput = input[swiftRange]
                    return String(ouput)
                }
            }
        } catch {
            return ""
        }
        return ""
    }
    
    static func toAcceptableDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    static func weekday(date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = NSCalendar.current
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: date).capitalizingFirstLetter()
        }
    }
    
    static func stringToDate(date: String, pattern: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = pattern
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
        let formattedDate = dateFormatter.date(from: date)
        if let date: Date = formattedDate {
            return date
        } else {
            print("[INFO] could not convert \(date) with pattern \(pattern) to date")
            return Date()
        }
    }
    
    
    // Credit to Robert Chen, thorntech.com
    static func parseAddress(selectedItem: MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        // put a comma between street and city/state
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        // put a space between "Washington" and "DC"
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            // street number
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            // street name
            selectedItem.thoroughfare ?? "",
            comma,
            // city
            selectedItem.locality ?? "",
            secondSpace,
            // state
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
    
    static func getShortAddress(placemark: MKPlacemark) -> String {
        // put a space between "4" and "Melrose Place"
        let firstSpace = (placemark.subThoroughfare != nil && placemark.thoroughfare != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@",
            // street number
            placemark.subThoroughfare ?? "",
            firstSpace,
            // street name
            placemark.thoroughfare ?? ""
        )
        return addressLine
    }
    
    // Credit to Robert Chen, thorntech.com
    static func parseCL(placemark: CLPlacemark?) -> String {
        if let selectedItem = placemark {
            // put a space between "4" and "Melrose Place"
            let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
            // put a comma between street and city/state
            let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
            // put a space between "Washington" and "DC"
            let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
            let addressLine = String(
                format:"%@%@%@%@%@%@%@",
                // street number
                selectedItem.subThoroughfare ?? "",
                firstSpace,
                // street name
                selectedItem.thoroughfare ?? "",
                comma,
                // city
                selectedItem.locality ?? "",
                secondSpace,
                // state
                selectedItem.administrativeArea ?? ""
            )
            return addressLine
        } else {
            return ""
        }
    }
    
    static func getAddressTable(placemark: CLPlacemark?) -> String {
        if let selectedItem = placemark {
            // put a space between "4" and "Melrose Place"
            let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
            let addressLine = String(
                format:"%@%@%@",
                // street number
                selectedItem.subThoroughfare ?? "",
                firstSpace,
                // street name
                selectedItem.thoroughfare ?? ""
            )
            return addressLine
        } else {
            return ""
        }
    }
    
    static func composeMessage(user: User?, game: Game?) -> String {
        let message = String(format: "%@%@%@%@%@%@%@",
                             user?.displayName() ?? "",
                             " is inviting you to a pick-up basketball game, ",
                             game?.name ?? "",
                             ", on ",
                             //                             game?.onDate() ?? "",
                             " at "//,
                             //                             game?.onTime() ?? ""
        )
        return message
    }
    
    static func coordinatesToPlacemark(latitude: Double, longitude: Double, completionHandler: @escaping (CLPlacemark?)
                                       -> Void ) {
        // use the last reported location
        let loc = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        // look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation(loc, completionHandler: { (placemarks, error) in
            if error == nil {
                let firstLocation = placemarks?[0]
                completionHandler(firstLocation)
            }
            else {
                // an error occurred during geocoding
                print("[INFO] an error occurred during geocoding with \(error!)")
                completionHandler(nil)
            }
        })
    }
    
    static func CLtoMK(placemark: CLPlacemark?) -> MKPlacemark? {
        var mk: MKPlacemark?
        if let p = placemark {
            if let address = p.postalAddress, let coordinate = p.location?.coordinate {
                mk = MKPlacemark(coordinate: coordinate, postalAddress: address)
            }
        }
        return mk
    }
    
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
