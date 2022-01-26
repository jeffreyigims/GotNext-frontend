//
//  Constants.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 3/30/21.
//  Copyright © 2021 Matthew Cruz. All rights reserved.
//

import Foundation

//let URL: String = "https://gotnext-backend.herokuapp.com"
let URL: String = "http://192.168.1.17:3000"
let GET_GAMES: String = "/get_games"
let GAMES: String = "/games"
let CREATE_USER: String = "/create_user"
let USERS: String = "/users"
let FAVORITES: String = "/favorites"
let PLAYERS: String = "/players"
let CONTACTS: String = "/contacts"
let SEARCH: String = "/search"

// icons
let addFriendsIcon: String = "person.badge.plus"
let myFriendsIcon: String = "person.3"
let chevronRight: String = "chevron.right"
let chevronDown: String = "chevron.down"
let defaultProfile: String = "person.crop.circle.fill"
let inviteContact: String = "paperplane.fill"

// tabview
let homeIcon: String = "house.circle.fill"
let profileIcon: String = "person.crop.circle.fill" // "person.crop.circle"

enum Page: Identifiable {
  case app, loginSplash, createUser, login, landing, sendingMessage
  var id: Int {
    hashValue
  }
}

enum Tab: Identifiable {
  case home, profile, invites
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
  case addingFriends, showingFriends, editingProfile
  var id: Int {
    hashValue
  }
}

enum Status: String, Codable, Identifiable {
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
  case notGoing, invited, maybe, going
  var id: Int {
    hashValue
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
}
