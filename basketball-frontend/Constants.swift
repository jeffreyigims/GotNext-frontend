//
//  Constants.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 3/30/21.
//  Copyright © 2021 Matthew Cruz. All rights reserved.
//

import Foundation

let URL: String = "http://secure-hollows-77457.herokuapp.com"
//let URL: String = "http://192.168.1.20:3000"
//let URL: String = "http://localhost:3000"
let GET_GAMES: String = "/get_games"
let GAMES: String = "/games"
let CREATE_USER: String = "/create_user"
let USERS: String = "/users"
let FAVORITES: String = "/favorites"
let PLAYERS: String = "/players"

enum Page: Identifiable {
  case app, loginSplash, createUser, login, landing
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
  case creatingGame, showingDetails, searchingUsers, selectingLocation
  var id: Int {
    hashValue
  }
}
