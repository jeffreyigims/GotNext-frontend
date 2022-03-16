//
//  Constants.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 3/30/21.
//  Copyright © 2021 Matthew Cruz. All rights reserved.
//

import Foundation
import SwiftUI

//let ADDRESS: String = "https://gotnext-backend.herokuapp.com"
let ADDRESS: String = "http://192.168.1.17:3000"
//let ADDRESS: String = "http://localhost:3000"
let GET_GAMES: String = "/get_games"
let GAMES: String = "/games"
let CREATE_USER: String = "/create_user"
let USERS: String = "/users"
let DEVICES: String = "/devices"
let FAVORITES: String = "/favorites"
let PLAYERS: String = "/players"
let CONTACTS: String = "/contacts"
let SEARCH: String = "/search"
let APPLE_AUTHENTICATE: String = "/apple_authenticate"

let APPLINK: String = "http://appstore.com/instagram"

// color
let primaryColor: Color = Color("primaryColor")

// icons
let addFriendsIcon: String = "person.badge.plus"
let myFriendsIcon: String = "person.2"
let chevronRight: String = "chevron.right"
let chevronDown: String = "chevron.down"
let defaultProfile: String = "person.crop.circle"
let inviteContact: String = "paperplane.fill"
let shareButton: String = "square.and.arrow.up"

let profileIconSize: CGFloat = 38
let defaultProfileIcon: String = "person.crop.circle.fill"

// tabview
let homeIcon: String = "house.circle.fill"
let profileIcon: String = "person.crop.circle.fill" // "person.crop.circle"

enum Page: Identifiable {
    case app, additionalInformation, loginSplash, createUser, login, landing, sendingMessage
    var id: Int {
        hashValue
    }
}

enum Tab: Identifiable {
    case home, profile
    var id: Int {
        hashValue
    }
}

enum Sheet: Identifiable {
    case creatingGame, showingDetails, searchingUsers, selectingLocation, gameInvites, discoveringFriends, sendingMessage, sharingGame
    var id: Int {
        hashValue
    }
}

enum Cover: Identifiable {
    case addingFriends, showingDetails, creatingGame, gameInvites, showingFriends, editingProfile, selectingLocation
    var id: Int {
        hashValue
    }
}

enum Status: String, Codable, CaseIterable, Identifiable {
    case notGoing, invited, maybe, going
    enum CodingKeys: CodingKey {
        case status
    }
    init(from decoder: Decoder) throws {
        let status = try decoder.singleValueContainer().decode(String.self)
        switch status {
        case "not_going":
            self = .notGoing
        case "invited":
            self = .invited
        case "maybe":
            self = .maybe
        case "going":
            self = .going
        default:
            self = .going
        }
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .notGoing:
            try container.encode("not_going", forKey: .status)
        case .invited:
            try container.encode("invited", forKey: .status)
        case .maybe:
            try container.encode("maybe", forKey: .status)
        case .going:
            try container.encode("going", forKey: .status)
        }
    }
    var isAffiliated: Bool {
        return self == .notGoing ? false : true
    }
    var id: Self { self }
    var color: Color {
        switch self {
        case .invited:
            return Color.green
        case .notGoing:
            return Color.red
        case .maybe:
            return Color.white
        case .going:
            return Color.green
        }
    }
    var encoding: String {
        switch self {
        case .invited:
            return "invited"
        case .notGoing:
            return "not_going"
        case .maybe:
            return "maybe"
        case .going:
            return "going"
        }
    }
    func toString() -> String {
        switch self {
        case .notGoing:
            return "Not Going"
        case .invited:
            return "Invited"
        case .maybe:
            return "Maybe"
        case .going:
            return "Going"
        }
    }
    var text: String {
        switch self {
        case .notGoing:
            return "Not Going"
        case .invited:
            return "Invited"
        case .maybe:
            return "Maybe"
        case .going:
            return "Going"
        }
    }
    
}
