//
//  Game.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 11/3/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import Foundation
import MapKit

let genericUser: Users = Users(id: 4, username: "mjordan", email: "mjordan@gmail.com", firstName: "Michael", lastName: "Jordan", dob: "12/10/1999", phone: "4123549286", favorite: -1)
let genericFavorite: Favorite = Favorite(id: 4, favoriter_id: 2, favoritee_id: 4, user: APIData<Users>(data: genericUser))
let genericUsers: [Users] = Array(repeating: genericUser, count: 4)

class Users: Codable, Identifiable {
  let id: Int
  let username: String
  let email: String
  let firstName: String
  let lastName: String
  let dob: String
  let phone: String
  var favorite: Int
  enum CodingKeys: String, CodingKey {
    case id, username, email, dob, phone, favorite
    case firstName = "firstname"
    case lastName = "lastname"
  }
  init(id: Int, username: String, email: String, firstName: String, lastName: String, dob: String, phone: String, favorite: Int) {
    self.id = id
    self.username = username
    self.email = email
    self.firstName = firstName
    self.lastName = lastName
    self.dob = dob
    self.phone = phone
    self.favorite = favorite
  }
  func displayName() -> String {
    return self.firstName + " " + self.lastName
  }
  func isFavorite() -> Bool { self.favorite != -1 }
}

class Games: NSObject, Codable, Identifiable, MKAnnotation {
  var id: Int
  let title: String?
  let subtitle: String?
  let coordinate: CLLocationCoordinate2D
  
  var name: String
  var date: String
  var time: String
  var desc: String
  var priv: Bool
  var longitude: Double
  var latitude: Double
  enum CodingKeys: String, CodingKey {
    case id, name, date, time, longitude, latitude
    case priv = "private"
    case desc = "description"
  }
  init(id: Int, name: String, date: String, time: String, desc: String, priv: Bool, longitude: Double, latitude: Double) {
    self.id = id
    self.name = name
    self.date = date
    self.time = time
    self.desc = desc
    self.priv = priv
    self.longitude = longitude
    self.latitude = latitude
    self.title = name
    self.subtitle = name
    self.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
  }
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(Int.self, forKey: .id)
    self.name = try container.decode(String.self, forKey: .name)
    self.date = try container.decode(String.self, forKey: .date)
    self.time = try container.decode(String.self, forKey: .time)
    self.desc = try container.decode(String.self, forKey: .desc)
    self.priv = try container.decode(Bool.self, forKey: .priv)
    self.longitude = try container.decode(Double.self, forKey: .longitude)
    self.latitude = try container.decode(Double.self, forKey: .latitude)
    self.title = self.name
    self.subtitle = self.name
    self.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
  }
  func onTime() -> String {
    return Helper.onTime(time: self.time)
  }
  func onDate() -> String {
    return Helper.onDate(date: self.date)
  }
}

struct Player: Codable, Identifiable {
  let id: Int
  let status: Status
  let game: APIData<Game>
  enum CodingKeys: String, CodingKey {
    case id
    case status
    case game
  }
}

struct Favorite: Codable, Identifiable {
  let id: Int
  let favoriter_id: Int
  let favoritee_id: Int
  let user: APIData<Users>
  enum CodingKeys: String, CodingKey {
    case id
    case favoriter_id
    case favoritee_id
    case user
  }
}

struct User: Codable {
  let id: Int
  let username: String
  let email: String
  let firstName: String
  let lastName: String
  let dob: String
  let phone: String
  let players: [APIData<Player>]
  let favorites: [APIData<Favorite>]
  let potentials: [APIData<Users>]
  let contacts: [APIData<Contact>]
  let profilePicture: String?
  enum CodingKeys: String, CodingKey {
    case id, username, email, dob, phone, players, favorites, potentials, contacts
    case firstName = "firstname"
    case lastName = "lastname"
    case profilePicture = "image"
  }
  func displayName() -> String {
    return self.firstName + " " + self.lastName
  }
}

struct Game: Codable {
  let id: Int
  let name: String
  let date: String
  let time: String
  let description: String
  let priv: Bool
  let longitude: Double
  let latitude: Double
  let invited: [APIData<Users>]
  let maybe: [APIData<Users>]
  let going: [APIData<Users>]
  enum CodingKeys: String, CodingKey {
    case id
    case name
    case date
    case time
    case description
    case priv = "private"
    case longitude
    case latitude
    case invited
    case maybe
    case going
  }
  func onTime() -> String {
    return Helper.onTime(time: self.time)
  }
  func onDate() -> String {
    return Helper.onDate(date: self.date)
  }
  func privDisplay() -> String {
    if self.priv {
      return "- Private"
    } else {
      return "- Public"
    }
  }
}

struct UserLogin: Decodable {
  let id: Int
  let username: String
  let api_key: String
  enum CodingKeys: String, CodingKey {
    case id
    case username
    case api_key
  }
}

struct ListData<T>: Codable where T: Codable {
  let data: [T]
  enum CodingKeys: String, CodingKey {
    case data
  }
  struct ListDataGenericData: Decodable {
    let id: String
    let type: String
    let attributes: T
    enum CodingKeys: String, CodingKey {
      case id
      case type
      case attributes
    }
  }
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let results = try container.decode([ListDataGenericData].self, forKey: .data)
    self.data = results.map({ $0.attributes })
  }
}

struct APIData<T>: Codable where T: Codable {
  var data: T
  enum CodingKeys: String, CodingKey {
    case data
  }
  struct DataGenericData: Decodable {
    let id: String
    let type: String
    let attributes: T
    enum CodingKeys: String, CodingKey {
      case id
      case type
      case attributes
    }
  }
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let results = try container.decode(DataGenericData.self, forKey: .data)
    self.data = results.attributes
  }
  init(data: T) {
    self.data = data
  }
}

extension Bundle {
  // Borrowed from Paul Hudson (@twostraws)
  func decode<T: Decodable>(_ type: T.Type, from file: String) -> T {
    guard let url = self.url(forResource: file, withExtension: nil) else {
      fatalError("Failed to locate \(file) in bundle.")
    }
    
    guard let data = try? Data(contentsOf: url) else {
      fatalError("Failed to load \(file) from bundle.")
    }
    
    let decoder = JSONDecoder()
    
    guard let loaded = try? decoder.decode(T.self, from: data) else {
      fatalError("Failed to decode \(file) from bundle.")
    }
    
    return loaded
  }
}


//dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
//timeFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
//dateFormatter.dateFormat = "yyyy-MM-dd"
//timeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//game.date = dateFormatter.date(from:game.date)
//game.time = timeFormatter.date(from:game.time)

class NormalizingDecoder: JSONDecoder {
  
  var dateFormatter: DateFormatter = DateFormatter()
  var timeFormatter: DateFormatter = DateFormatter()
  let calendar = Calendar.current
  
  override init() {
    super.init()
    //    dateFormatter = DateFormatter()
    dateFormatter.timeStyle = .medium
    keyDecodingStrategy = .convertFromSnakeCase
    dateFormatter.dateFormat = "yyyy-MM-dd"
    timeFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    dateDecodingStrategy = .custom { (decoder) -> Date in
      let container = try decoder.singleValueContainer()
      let dateString = try container.decode(String.self)
      let date = self.dateFormatter.date(from: dateString)
      
      if let date = date {
        let midnightThen = self.calendar.startOfDay(for: date)
        let millisecondsFromMidnight = date.timeIntervalSince(midnightThen)
        
        let today = Date()
        let midnightToday = self.calendar.startOfDay(for: today)
        let normalizedDate = midnightToday.addingTimeInterval(millisecondsFromMidnight)
        
        return normalizedDate
      } else {
        throw DecodingError.dataCorruptedError(in: container,
                                               debugDescription:
                                                "Date values must be formatted like \"7:27:02 AM\" " +
                                                "or \"12:16:28 PM\".")
      }
    }
  }
}


