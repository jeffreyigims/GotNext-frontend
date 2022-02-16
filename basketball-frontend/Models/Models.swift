//
//  Game.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 11/3/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//

import Foundation
import MapKit

let genericCurrentUser: User = User(id: 4, username: "mjordan", email: "mjordan@gmail.com", firstName: "Michael", lastName: "Jordan", dob: "12/10/1999", phone: "4123549286", games: [Game](), favorites: [Favorite](), favoritees: [Users](), potentials: [Users](), contacts: [Contact](), profilePicture: nil)
let genericUser: Users = Users(id: 4, username: "mjordan", email: "mjordan@gmail.com", firstName: "Michael", lastName: "Jordan", dob: "12/10/1999", phone: "4123549286", favorite: -1)
let genericFavorite: Favorite = Favorite(id: 3, favoriter_id: 2, favoritee_id: 4, user: APIData<Users>(data: genericUser))
let genericUsers: [Users] = [genericUser, Users(id: 9, username: "mjordan", email: "mjordan@gmail.com", firstName: "Michael", lastName: "Jordan", dob: "12/10/1999", phone: "4123549286", favorite: 4), Users(id: 5, username: "mjordan", email: "mjordan@gmail.com", firstName: "Michael", lastName: "Jordan", dob: "12/10/1999", phone: "4123549286", favorite: -1), Users(id: 7, username: "mjordan", email: "mjordan@gmail.com", firstName: "Michael", lastName: "Jordan", dob: "12/10/1999", phone: "4123549286", favorite: 7), Users(id: 8, username: "mjordan", email: "mjordan@gmail.com", firstName: "Michael", lastName: "Jordan", dob: "12/10/1999", phone: "4123549286", favorite: -1)]
let genericGame: Game = Game(id: 4, name: "Carnegie Game", date: "2021-05-15", time: "2000-01-01T22:57:58.075Z", description: "This game will be played at Carnegie Mellon campus and will be open to the public", priv: true, longitude: -79.94456661125692, latitude: 40.441405662286684, invited: [Users](), maybe: [Users](), going: [Users](), player: nil)
let genericGames: [Game] = [Game(id: 4, name: "CMU Game", date: "2021-05-15", time: "2000-01-01T22:57:58.075Z", description: "This game will be played at Carnegie Mellon campus and will be open to the public", priv: true,   longitude: -79.94456661125692, latitude: 40.441405662286684, invited: [Users](), maybe: [Users](), going: [Users](), player: nil),
                            Game(id: 5, name: "CMU Game", date: "2021-05-15", time: "2000-01-01T22:57:58.075Z", description: "This game will be played at Carnegie Mellon campus and will be open to the public", priv: true,   longitude: -79.94456661125692, latitude: 40.441405662286684, invited: [Users](), maybe: [Users](), going: [Users](), player: nil),
                            Game(id: 6, name: "CMU Game", date: "2021-05-17", time: "2000-01-01T22:57:58.075Z", description: "This game will be played at Carnegie Mellon campus and will be open to the public", priv: true,   longitude: -79.94456661125692, latitude: 40.441405662286684, invited: [Users](), maybe: [Users](), going: [Users](), player: nil),
                            Game(id: 7, name: "CMU Game", date: "2021-05-17", time: "2000-01-01T22:57:58.075Z", description: "This game will be played at Carnegie Mellon campus and will be open to the public", priv: true,   longitude: -79.94456661125692, latitude: 40.441405662286684, invited: [Users](), maybe: [Users](), going: [Users](), player: nil)]

struct Player: Codable, Identifiable {
    let id: Int
    let status: Status
    enum CodingKeys: String, CodingKey {
        case id
        case status
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


