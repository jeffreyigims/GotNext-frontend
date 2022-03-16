//
//  User.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 2/8/22.
//  Copyright © 2022 Matthew Cruz. All rights reserved.
//

import Foundation
import SwiftUI
import AuthenticationServices

class PotentialUser {
    let userId: String
    let identityToken: Data?
    let authCode: Data?
    var email: String
    var givenName: String
    var familyName: String
    let state: String?
    var phone: String = ""
    var dob: Date = Date()
    init(userId: String, identityToken: Data?, authCode: Data?, email: String?, givenName: String?, familyName: String?, state: String?) {
        self.userId = userId
        self.identityToken = identityToken
        self.authCode = authCode
        self.email = email ?? ""
        self.givenName = givenName ?? ""
        self.familyName = familyName ?? ""
        self.state = state
    }
}

class User: Codable, Identifiable {
    let id: Int
    let username: String
    var email: String
    var firstName: String
    var lastName: String
    let dob: String
    var phone: String
    let games: [Game]
    var favorites: [Users]
    var favoritees: [Users]
    let potentials: [Users]
    let contacts: [Contact]
    let profilePicture: String?
    var picture: Image
    enum CodingKeys: String, CodingKey {
        case id, username, email, dob, phone, games, favorites, favoritees, potentials, contacts
        case firstName = "firstname"
        case lastName = "lastname"
        case profilePicture = "image"
    }
    init(id: Int, username: String, email: String, firstName: String, lastName: String, dob: String, phone: String, games: [Game], favorites: [Users], favoritees: [Users], potentials: [Users], contacts: [Contact], profilePicture: String?) {
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
        self.picture = Image(systemName: defaultProfile)
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
        self.favorites = try container.decode([APIData<Users>].self, forKey: .favorites).map { $0.data }
        self.favoritees = try container.decode([APIData<Users>].self, forKey: .favoritees).map { $0.data }
        self.potentials = try container.decode([APIData<Users>].self, forKey: .potentials).map { $0.data }
        self.contacts = try container.decode([APIData<Contact>].self, forKey: .contacts).map { $0.data }
        self.profilePicture = try container.decode(String?.self, forKey: .profilePicture)
        
        
        if let profilePicLink: String = self.profilePicture {
            if let url: URL = URL(string: profilePicLink) {
                if let data: Data = try? Data(contentsOf: url) {
                    if let img: UIImage = UIImage(data: data) {
                        self.picture = Image(uiImage: img)
                        return
                    }
                }
            }
        }
        self.picture = Image(systemName: defaultProfileIcon)
    }
    func displayName() -> String {
        return self.firstName + " " + self.lastName
    }
    func gamesForStatus(status: Status) -> [Game] {
        return self.games.filter { game in game.player.status == status }
    }
}

class Users: Codable, Identifiable, Equatable {
    let id: Int
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let dob: String
    let phone: String
    var favorite: Int
    let profilePicture: String?
    enum CodingKeys: String, CodingKey {
        case id, username, email, dob, phone, favorite
        case firstName = "firstname"
        case lastName = "lastname"
        case profilePicture = "image"
    }
    init(id: Int, username: String, email: String, firstName: String, lastName: String, dob: String, phone: String, favorite: Int, profilePicture: String?) {
        self.id = id
        self.username = username
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.dob = dob
        self.phone = phone
        self.favorite = favorite
        self.profilePicture = profilePicture
    }
    static func == (lhs: Users, rhs: Users) -> Bool {
        lhs.id == rhs.id
    }
    func displayName() -> String {
        return self.firstName + " " + self.lastName
    }
    func isFavorite() -> Bool { self.favorite != -1 }
}

