//
//  User.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 2/8/22.
//  Copyright © 2022 Matthew Cruz. All rights reserved.
//

import Foundation

class User: Codable, Identifiable {
    let id: Int
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let dob: String
    let phone: String
    let games: [Game]
    let favorites: [Favorite]
    let favoritees: [Users]
    let potentials: [Users]
    let contacts: [Contact]
    let profilePicture: String?
    enum CodingKeys: String, CodingKey {
        case id, username, email, dob, phone, games, favorites, favoritees, potentials, contacts
        case firstName = "firstname"
        case lastName = "lastname"
        case profilePicture = "image"
    }
    init(id: Int, username: String, email: String, firstName: String, lastName: String, dob: String, phone: String, games: [Game], favorites: [Favorite], favoritees: [Users], potentials: [Users], contacts: [Contact], profilePicture: String?) {
        self.id = id
        self.username = username
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.dob = dob
        self.phone = phone
        self.games = games
        self.favorites = favorites
        self.favoritees = favoritees
        self.potentials = potentials
        self.contacts = contacts
        self.profilePicture = profilePicture
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.username = try container.decode(String.self, forKey: .username)
        self.email = try container.decode(String.self, forKey: .email)
        self.firstName = try container.decode(String.self, forKey: .firstName)
        self.lastName = try container.decode(String.self, forKey: .lastName)
        self.dob = try container.decode(String.self, forKey: .dob)
        self.phone = try container.decode(String.self, forKey: .phone)
        self.games = try container.decode([APIData<Game>].self, forKey: .games).map { $0.data }
        self.favorites = try container.decode([APIData<Favorite>].self, forKey: .favorites).map { $0.data }
        self.favoritees = try container.decode([APIData<Users>].self, forKey: .favoritees).map { $0.data }
        self.potentials = try container.decode([APIData<Users>].self, forKey: .potentials).map { $0.data }
        self.contacts = try container.decode([APIData<Contact>].self, forKey: .contacts).map { $0.data }
        self.profilePicture = try container.decode(String.self, forKey: .profilePicture)
    }
    func displayName() -> String {
        return self.firstName + " " + self.lastName
    }
    func gamesForStatus(status: Status) -> [Game] {
        return self.games.filter { game in game.player?.status == status }
    }
}

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

