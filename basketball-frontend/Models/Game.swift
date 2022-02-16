//
//  Game.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 2/15/22.
//  Copyright © 2022 Matthew Cruz. All rights reserved.
//

import Foundation
import MapKit

class Game: Codable, Identifiable {
    let id: Int
    let name: String
    let date: String
    let time: String
    let description: String
    let priv: Bool
    let longitude: Double
    let latitude: Double
    let invited: [Users]
    let maybe: [Users]
    let going: [Users]
    let player: Player?
    enum CodingKeys: String, CodingKey {
        case id, name, date, time, description, longitude, latitude, invited, maybe, going, player
        case priv = "private"
    }
    init(id: Int, name: String, date: String, time: String, description: String, priv: Bool, longitude: Double, latitude: Double, invited: [Users], maybe: [Users], going: [Users], player: Player?) {
        self.id = id
        self.name = name
        self.date = date
        self.time = time
        self.description = description
        self.priv = priv
        self.longitude = longitude
        self.latitude = latitude
        self.invited = invited
        self.maybe = maybe
        self.going = going
        self.player = player
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.date = try container.decode(String.self, forKey: .date)
        self.time = try container.decode(String.self, forKey: .time)
        self.description = try container.decode(String.self, forKey: .description)
        self.priv = try container.decode(Bool.self, forKey: .priv)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.invited = try container.decode([APIData<Users>].self, forKey: .invited).map { $0.data }
        self.maybe = try container.decode([APIData<Users>].self, forKey: .maybe).map { $0.data }
        self.going = try container.decode([APIData<Users>].self, forKey: .going).map { $0.data }
        self.player = try container.decode(APIData<Player>?.self, forKey: .player)?.data
    }
    func onTime() -> String {
        return Helper.onTime(time: self.time)
    }
    func onDate() -> String {
        return Helper.onDate(date: self.date)
    }
    func privDisplay() -> String {
        if self.priv { return "- Private" }
        else { return "- Public" }
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
