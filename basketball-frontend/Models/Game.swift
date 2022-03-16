//
//  Game.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 2/15/22.
//  Copyright © 2022 Matthew Cruz. All rights reserved.
//

import Foundation
import MapKit

class Game: NSObject, Codable, Identifiable, MKAnnotation, ObservableObject {
    let id: Int
    let name: String
    var title: String?
    var subtitle: String?
    let date: Date
    let desc: String
    let priv: Bool
    let longitude: Double
    let latitude: Double
    var coordinate: CLLocationCoordinate2D
    let shortAddress: String
    let longAddress: String
    @Published var invited: [Users]
    @Published var maybe: [Users]
    @Published var going: [Users]
    @Published var player: Player
    enum CodingKeys: String, CodingKey {
        case id, date, time, longitude, latitude, invited, maybe, going, player, shortAddress, longAddress
        case name = "name"
        case priv = "private"
        case desc = "description"
    }
    init(id: Int, name: String, date: String, time: String, desc: String, priv: Bool, longitude: Double, latitude: Double, invited: [Users], maybe: [Users], going: [Users], player: Player, shortAddress: String, longAddress: String) {
        self.id = id
        self.name = name
        self.title = name
        self.subtitle = name
        self.date = Helper.toDate(timeString: time, dateString: date)
        self.desc = desc
        self.priv = priv
        self.longitude = longitude
        self.latitude = latitude
        self.invited = invited
        self.maybe = maybe
        self.going = going
        self.player = player
        self.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        self.shortAddress = shortAddress
        self.longAddress = longAddress
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.title = self.name
        self.subtitle = self.title
        
        let date = try container.decode(String.self, forKey: .date)
        let time = try container.decode(String.self, forKey: .time)
        self.date = Helper.toDate(timeString: time, dateString: date)
      
        self.priv = try container.decode(Bool.self, forKey: .priv)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.invited = try container.decode([APIData<Users>].self, forKey: .invited).map { $0.data }
        self.maybe = try container.decode([APIData<Users>].self, forKey: .maybe).map { $0.data }
        self.going = try container.decode([APIData<Users>].self, forKey: .going).map { $0.data }
        
        // give default description if none is provided
        let description = try container.decode(String.self, forKey: .desc)
        self.desc = description.isEmpty ? "This is a game titled \(self.name)" : description
        
        // assign a default player if none is provided
        if let player = try container.decode(APIData<Player>?.self, forKey: .player)?.data {
            self.player = player
        } else { self.player = Player(id: -1, status: Status.notGoing)}
        
        self.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        self.shortAddress = try container.decode(String.self, forKey: .shortAddress)
        self.longAddress = try container.decode(String.self, forKey: .longAddress)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
//    func onTime() -> String {
//        return Helper.onTime(time: self.time)
//    }
//    func onDate() -> String {
//        return Helper.onDate(date: self.date)
//    }
//    func toDate() -> Date {
//        return Helper.toDate(date: self.date)
//    }
    func privDisplay() -> String {
        if self.priv { return "- Private" }
        else { return "- Public" }
    }
    func filterUser(status: Status, user: Users) -> () {
        switch status {
        case .notGoing:
            return
        case .invited:
            self.invited = self.invited.filter { $0 != user }
        case .maybe:
            self.maybe = self.maybe.filter { $0 != user }
        case .going:
            self.going = self.going.filter { $0 != user }
        }
    }
    func addUser(status: Status, user: Users) -> () {
        switch status {
        case .notGoing:
            return
        case .invited:
            self.invited.append(user)
        case .maybe:
            self.maybe.append(user)
        case .going:
            self.going.append(user)
        }
    }
    func switchUser(currStatus: Status, newStatus: Status, user: Users) -> () {
        self.addUser(status: newStatus, user: user)
        self.filterUser(status: currStatus, user: user)
    }
    func forStatus(status: Status) -> [Users] {
        switch status {
        case .notGoing:
            return self.invited
        case .invited:
            return self.invited
        case .maybe:
            return self.maybe
        case .going:
            return self.going
        }
    }
    func sortForStatus(status: Status, sort: (Users, Users) -> Bool) -> () {
        switch status {
        case .notGoing:
            self.invited.sort(by: sort)
        case .invited:
            self.invited.sort(by: sort)
        case .maybe:
            self.maybe.sort(by: sort)
        case .going:
            self.going.sort(by: sort)
        }
    }
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
        let desc = try container.decode(String.self, forKey: .desc)
        self.desc = desc.isEmpty ? "This is a game titled \(self.name)" : desc
        self.priv = try container.decode(Bool.self, forKey: .priv)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.title = self.name
        self.subtitle = self.name
        self.coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
//    func onTime() -> String {
//        return Helper.onTime(time: self.time)
//    }
//    func onDate() -> String {
//        return Helper.onDate(date: self.date)
//    }
}

class GenericGameGroup: Identifiable, Comparable, Equatable {
    let id: UUID = UUID()
    let date: Date
    let games: [Game]
    init(date: String, games: [Game]) {
        self.date = Helper.stringToDate(date: date, pattern: "YYYY-MM-dd")
        self.games = games
    }
    static func < (lhs: GenericGameGroup, rhs: GenericGameGroup) -> Bool {
        lhs.date < rhs.date
    }
    
    static func == (lhs: GenericGameGroup, rhs: GenericGameGroup) -> Bool {
        lhs.date == rhs.date
    }
}
