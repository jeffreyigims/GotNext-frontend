//
//  ViewModel.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 11/3/20.
//  Copyright © 2020 Matthew Cruz. All rights reserved.
//
import Foundation
import Alamofire
import SwiftUI
import Photos
import Contacts
import MessageUI
import MapKit

struct Request<T> {
    let method: HTTPMethod
    let params: Parameters
    let exten: String
    let success: ((AFDataResponse<T>) -> ())
    let failure: ((AFDataResponse<T>) -> ())
}

class ViewModel: ObservableObject {
    
    let appDelegate: AppDelegate = AppDelegate()
    
    // list of all games
    @Published var games: [Games] = [Games]()
    // games converted to class, allowing them to become map markers
    @Published var gameAnnotations: [GameAnnotation] = [GameAnnotation]()
    
    @Published var user: User = genericCurrentUser
    @Published var players: [Player] = [Player]()
    @Published var userGames: [Game] = [Game]()
    @Published var invitedGames: [Game] = [Game]()
    @Published var groupedPlayers: [Dictionary<String, [Player]>.Element] = [Dictionary<String, [Player]>.Element]()
    @Published var groupedGamesGoing: [Dictionary<String, [Game]>.Element] = [Dictionary<String, [Game]>.Element]()

    // set of games associated with the players of the user
    @Published var playersSet: Set<Int> = Set()

    // users favorited by the user
    @Published var favorites: [Users] = [Users]()
    // set of user identifications who are favorited by the current user
    @Published var favoritesSet: Set<Int> = Set()
    // users who have favorited the user
    @Published var favoritees: [Users] = [Users]()
    
    @Published var userId: Int?
    var headers: HTTPHeaders?
    
    @Published var sharingContent: Bool = false
    
    @Published var game: Game = Game(id: -1, name: "Generic Game", date: "2021-05-15", time: "2000-01-01 14:50:19", description: "", priv: true, longitude: -79.94456661125692, latitude: 40.441405662286684, invited: [Users](), maybe: [Users](), going: [Users](), player: nil)
    @Published var player: Player = Player(id: -1, status: Status.going)
    @Published var invited: [Users] = [Users]()
    @Published var maybe: [Users] = [Users]()
    @Published var going: [Users] = [Users]()
    
    @Published var gamePlayers: Set<Int> = Set()
    
    @Published var userLocation = Location()
    @Published var currentScreen: Page = Page.landing
    @Published var currentTab: Tab = Tab.home
    @Published var searchResults: [Users] = [Users]()
    
    // contacts of the user who are also on the app but have not yet been favorited
    @Published var potentials: [Users] = [Users]()
    // contacts of the user
    @Published var contactPotentials: [Contact] = [Contact]()
    
    @Published var isLoaded: Bool = false
    @Published var alert: Alert?
    @Published var showAlert: Bool = false
    
    @Published var activeSheet: Sheet = .creatingGame
    @Published var showingSheet: Bool = false
    
    @Published var activeCover: Cover = .addingFriends
    @Published var showingCover: Bool = false
    
    @Published var settingLocation: Bool = false
    @Published var selectedLocation: CLPlacemark? = nil
    
    @Published var contacts: [Contact] = [Contact]()
    @Published var contactsFiltered: [Contact] = [Contact]()
    @Published var contact: Contact?
    
    var secureStoreWithGenericPwd: SecureStore!
    
    func request<T>(req: Request<T>) where T : Decodable {
        AF.request(ADDRESS + req.exten, method: req.method, parameters: req.params, headers: self.headers!)
            .validate()
            .responseDecodable {
                ( response: AFDataResponse<T>) in
                switch response.result {
                case .success:
                    req.success(response)
                case .failure:
                    req.failure(response)
                }
            }
    }
    
    func sendContacts() {
        let success: (AFDataResponse<APIData<User>>) -> () = { (value) in
            if let _: APIData<User> = value.value {
                
                print("[INFO] successfully sent contacts")
            }}
        let failure: (AFDataResponse<APIData<User>>) -> () = { (value) in
        }
        let data = self.contacts.map({ $0.asDictionary() })
        let params: [String : Any] = [
            "user": self.user.id,
            "data": data
        ]
        AF.request(ADDRESS + CONTACTS, method: .post, parameters: params, encoding: JSONEncoding.default, headers: self.headers!)
            .validate()
            .responseDecodable {
                ( response: AFDataResponse<APIData<User>>) in
                switch response.result {
                case .success:
                    success(response)
                case .failure:
                    failure(response)
                }
            }
    }
    
    //
    // USER FUNCTIONS
    //
    
    // checks to see if prior credentials were stored in the keychain
    func tryLogin() {
        let genericPwdQueryable = GenericPasswordQueryable(service: "MyService")
        secureStoreWithGenericPwd = SecureStore(secureStoreQueryable: genericPwdQueryable)
        do {
            let credentials = try secureStoreWithGenericPwd.getValue(for: "genericPassword")
            if let components = credentials?.components(separatedBy: ":") {
                login(username: components.first ?? "", password: components.last ?? "")
            }
        } catch (let e) { print("Could not get password with \(e.localizedDescription)") }
    }
    
    //  perform login for a user
    //  :param username (String) - username of the user
    //  :param password (String) - password of the user in plain text
    //  :return none
    func login(username: String, password: String) {
        let genericPwdQueryable = GenericPasswordQueryable(service: "MyService")
        secureStoreWithGenericPwd = SecureStore(secureStoreQueryable: genericPwdQueryable)
        self.currentScreen = Page.loginSplash
        let credentials: String = username + ":" + password
        let encodedCredentials: String = Data(credentials.utf8).base64EncodedString()
        do {
            try secureStoreWithGenericPwd.setValue(credentials, for: "genericPassword")
        } catch (let e) { print("[INFO] could not save password with \(e.localizedDescription)") }
        let headers: HTTPHeaders = ["Authorization": "Basic " + encodedCredentials]
        AF.request(ADDRESS + "/token/", headers: headers)
            .validate()
            .responseDecodable {
                ( response: AFDataResponse<UserLogin> ) in
                switch response.result {
                case .success:
                    if let value: UserLogin = response.value {
                        let token = value.api_key
                        self.userId = value.id
                        self.createAuthHeader(token: token)
                        self.refreshCurrentUser()
                        self.getGames()
                        self.fetchContacts()
                        self.currentScreen = Page.app
                    }
                case .failure:
                    self.currentScreen = Page.login
                    self.alert = self.createAlert(title: "Invalid Login",
                                                  message: "The username or password you entered was invalid",
                                                  button: "Got it")
                    self.showAlert = true
                }
            }
    }
    
    func tryLogout() {
        self.alert = Alert(title: Text("Sign out?"),
                           message: Text("You can always access your content by signing back in"),
                           primaryButton: .cancel({ self.showAlert = false }),
                           secondaryButton: .destructive(Text("Sign Out"), action: { self.logout() }))
        self.showAlert = true
    }
    
    //  perform logout for a user by clearing all stored variables in ViewModel
    //  :param none
    //  :return none
    func logout() {
        do {
            try secureStoreWithGenericPwd.removeValue(for: "genericPassword")
        } catch (let e) {
            print("Could not remove password with \(e.localizedDescription)")
        }
        
        self.games = [Games]()
        self.players = [Player]()
        self.playersSet = Set()
        self.favoritesSet = Set()
        self.userId = nil
        self.headers = nil
        self.invited = [Users]()
        self.maybe = [Users]()
        self.going = [Users]()
        self.gamePlayers = Set()
        self.userLocation = Location()
        self.currentScreen = Page.landing
        self.searchResults = [Users]()
        self.isLoaded = false
        self.alert = nil
        self.showAlert = false
    }
    
    //  refresh the current user by updating self.user
    //  :param none
    //  :return none
    func refreshCurrentUser() {
        let request = ADDRESS + "/users/" + String(self.userId!)
        AF.request(request, headers: self.headers!).responseDecodable { ( response: AFDataResponse<APIData<User>> ) in
            print(response)
            if let value: APIData<User> = response.value {
                self.user = value.data
                self.userGames = value.data.games
                self.invitedGames = self.user.gamesForStatus(status: Status.invited)
                self.favorites = value.data.favorites.map { fav in Users(id: fav.favoritee_id, username: fav.user.data.username, email: fav.user.data.email, firstName: fav.user.data.firstName, lastName: fav.user.data.lastName, dob: fav.user.data.dob, phone: fav.user.data.phone, favorite: fav.id)}
                self.favoritesSet = Set(value.data.favorites.map { $0.user.data.id })
                self.potentials = value.data.potentials
                self.contactPotentials = value.data.contacts
                self.favoritees = value.data.favoritees
            }
        }
    }
    
    //  create a new user
    //  :param firstName (String) - user's first name
    //  :param lastName (String) - user's last name
    //  :param username (String) - user's username
    //  :param email (String) - user's email, must be a valid email address
    //  :param dob (Date) - user's date of birth
    //  :param phone (String) - user's phone number, must be a valid phone number
    //  :param password (String) - user password, at least 6 characters
    //  :param passwordConfirmation (String) - a confirmation of user password, should be the same as password
    //  :return (User?) - a user object if the user is successfully created, nil otherwise
    func createUser(firstName: String, lastName: String, username: String, email: String, dob: Date, phone: String, password: String, passwordConfirmation: String) -> () {
        let acceptableDate = Helper.toAcceptableDate(date: dob)
        let params = [
            "firstname": firstName,
            "lastname": lastName,
            "username": username,
            "email": email,
            "dob": acceptableDate,
            "phone": phone,
            "password": password,
            "password_confirmation": passwordConfirmation
        ]
        let success: (AFDataResponse<APIData<User>>) -> () = { (value) in
            if let _: APIData<User> = value.value {
                self.login(username: username, password: password)
            }}
        let failure: (AFDataResponse<APIData<User>>) -> () = { (value) in
            self.alert = self.createAlert(title: "Invalid Profile Information",
                                          message: "The profile information you entered was invalid, please check your inputs and try again",
                                          button: "Got it")
            self.showAlert = true
        }
        let req: Request = Request(method: .post, params: params, exten: CREATE_USER, success: success, failure: failure)
        AF.request(ADDRESS + req.exten, method: req.method, parameters: req.params)
            .validate()
            .responseDecodable {
                ( response: AFDataResponse<APIData<User>>) in
                switch response.result {
                case .success:
                    req.success(response)
                case .failure:
                    req.failure(response)
                }
            }
    }
    
    //  edit the current user
    //  :param firstName (String) - first name of the user
    //  :param lastName (String) - last name of the user
    //  :param username (String) - username of the user, must be unique
    //  :param email (String) - email of the user, must be correctly formatted
    //  :param phone (String) - phone number of the user, must be correctly formatted
    //  :return none
    func editCurrentUser(firstName: String, lastName: String, username: String, email: String, phone: String, image: UIImage?) -> () {
        let encoding: String = "data:image/jpeg;base64,[\(image!.jpegData(compressionQuality: 0.7)?.base64EncodedString() ?? "")]"
        let params: [String : Any] = [
            "firstname": firstName,
            "lastname": lastName,
            "username": username,
            "email": email,
            "dob": self.user.dob,
            "phone": phone,
            "image": ["data": encoding],
            "password": "secret",
            "password_confirmation": "secret"
        ]
        let success: (AFDataResponse<APIData<User>>) -> () = { (value) in
            if let value: APIData<User> = value.value {
                self.user = value.data
                self.showingCover.toggle()
                print("[INFO] successfully updated current user to \(value.data)")
            }}
        let failure: (AFDataResponse<APIData<User>>) -> () = { (value) in print(value)
            self.alert = self.createAlert(title: "Invalid Profile Information",
                                          message: "The edited profile information you entered was invalid, please check your inputs and try again",
                                          button: "Close")
            self.showAlert = true
        }
        let req: Request = Request(method: .patch, params: params, exten: USERS+"/"+String(self.user.id), success: success, failure: failure)
        request(req: req)
    }
    
    func setLocation() -> () {
        self.currentTab = Tab.home
        self.showingCover = false
        self.settingLocation = true
    }
    
    //
    // GAME FUNCTIONS
    //
    
    //  get all games
    //  :param none
    //  :return none
    func getGames() {
        print("GET GAMES")
        let params: Parameters = [
            "user_id": self.userId!
        ]
        let success: (AFDataResponse<ListData<Games>>) -> () = { (value) in
            if let value: ListData<Games> = value.value {
                self.games = value.data
                self.gameAnnotations = value.data.map({ GameAnnotation(id: $0.id, subtitle: $0.name, title: $0.name, latitude: $0.latitude, longitude: $0.longitude)})
                print("Annotations")
                print(self.gameAnnotations)
            }}
        let failure: (AFDataResponse<ListData<Games>>) -> () = { (value) in }
        let req: Request = Request(method: .get, params: params, exten: GET_GAMES, success: success, failure: failure)
        request(req: req)
    }
    
    //  get a game by ID
    //  id (Int?) - the id for a game
    //  return (none)
    func getGame(id: Int?) {
        guard let identification = id else {
            return
        }
        let params: Parameters = [:]
        let success: (AFDataResponse<APIData<Game>>) -> () = { (value) in
            if let value: APIData<Game> = value.value {
                self.game = value.data
                self.invited = value.data.invited
                self.maybe = value.data.maybe
                self.going = value.data.going
                let arr = self.invited + self.maybe + self.going
                self.gamePlayers = Set(arr.map { $0.id })
            }}
        let failure: (AFDataResponse<APIData<Game>>) -> () = { (value) in print(value) }
        let req: Request = Request(method: .get, params: params, exten: GAMES+"/"+String(identification), success: success, failure: failure)
        request(req: req)
    }
    //
    //    func findPlayer(gameId: String) {
    //        if let i = Int(gameId) {
    //            let players = self.players.filter({ $0.game.data.id == i })
    //            // There is already a player object associated with this game
    //            if players.count >= 1 {
    //                self.player = players.first
    //            } else {
    //                self.player = nil
    //            }
    //        }
    //    }
    //
    //  create a new game
    //  :param name (String) - name of the game court
    //  :date (Date) - date and time of the game
    //  :description (String) - description of the game
    //  :priv (Bool) - whether the game is private
    //  :latitude (Double) - latitude of the game location
    //  :longitude: (Double) - longitude of the game location
    //  :return (Game?) - the game object if created successfully, nil otherwise
    func createGame(name: String, date: Date, description: String, priv: Bool, latitude: Double, longitude: Double) -> () {
        let acceptableDate = Helper.toAcceptableDate(date: date)
        let params: Parameters = [
            "name": name,
            "date": acceptableDate,
            "time": acceptableDate,
            "description": description,
            "private": priv,
            "longitude": longitude,
            "latitude": latitude
        ]
        let success: (AFDataResponse<APIData<Game>>) -> () = { (value) in
            if let value: APIData<Game> = value.value {
                self.showingSheet = false
                self.game = value.data
                self.createPlayer(status: "going", userId: self.user.id, gameId: value.data.id)
                //        if let newGame = self.game {
                let newGame = Games(id: self.game.id, name: self.game.name, date: self.game.date, time: self.game.time, desc: self.game.description, priv: self.game.priv, longitude: self.game.longitude, latitude: self.game.latitude)
                self.games.append(newGame)
                let gameAnnotation = GameAnnotation(id: newGame.id, subtitle: newGame.name, title: newGame.name, latitude: newGame.latitude, longitude: newGame.longitude)
                self.gameAnnotations.append(gameAnnotation)
                self.cancelSelectingLocation()
                //        }
            }
            self.activeSheet = .showingDetails
            self.showingSheet = true
        }
        let failure: (AFDataResponse<APIData<Game>>) -> () = { (value) in
            self.alert = Alert(title: Text("Create Game Failed"),
                               message: Text("Failed to create this game, please try again"),
                               dismissButton: .default(Text("Close"), action: { self.showAlert = false }))
            self.showAlert = true }
        let req: Request = Request(method: .post, params: params, exten: GAMES, success: success, failure: failure)
        request(req: req)
    }
    
    //
    // SHEET FUNCTIONS
    //
    
    func shareGame() -> () {
        self.activeSheet = .sharingGame
        self.showingSheet = true
    }
    
    func startCreating() -> () {
        self.showingCover = true
        self.activeCover = .creatingGame
    }
    
    func showDetails() -> () {
        self.showingCover = true
        self.activeCover = .showingDetails
    }
    
    func searchUsers() -> () {
        self.showingSheet = true
        self.activeSheet = .searchingUsers
    }
    
    func discoveringFriends() -> () {
        self.showingSheet = true
        self.activeSheet = .discoveringFriends
    }
    
    func selectingLocation() -> () {
        self.showingCover = true
        self.activeCover = .selectingLocation
    }
    
    func showInvites() -> () {
        self.showingCover = true
        self.activeCover = .gameInvites
    }
    
    func cancelSelectingLocation() -> () {
        self.settingLocation = false
    }
    
    func showGame(game: Game) -> () {
        if let player: Player = game.player {
            self.player = player
        } else {
            
        }
        self.player = game.player!
        self.getGame(id: game.id)
        self.showDetails()
    }
    
    // invites a user from the user's contacts to the game
    // :param contact (Contact) - the contact who is being invited
    // :return none
    func inviteContact(contact: Contact) -> () {
        self.contact = contact
        self.activeSheet = .sendingMessage
        self.showingSheet = true
    }
    
    // called when the sheet is dismissed
    func dismissSheet() -> () {
        switch self.activeSheet {
        default:
            return
        }
    }
    
    // called when the cover is dismissed
    func dismissCover() -> () {
        switch self.activeCover {
        default:
            return
        }
    }
    
    func editProfile() -> () {
        self.activeCover = .editingProfile
        self.showingCover = true
    }
    
    //
    // FAVORITE FUNCTIONS
    //
    
    //  favorite another user and refresh the user info
    //  :param favoriterId (Int) - user ID of the favoriter
    //  :param favoriteeId (Int) - user ID of the favoritee
    //  :return Void
    func favorite(favoritee: Users) -> () {
        let params = [
            "favoriter_id": self.user.id,
            "favoritee_id": favoritee.id
        ]
        let success: (AFDataResponse<APIData<Favorite>>) -> () = { (value) in
            if let favorite: APIData<Favorite> = value.value {
                self.refreshCurrentUser()
                // add favorite object identification to favoritee user
                favoritee.favorite = favorite.data.id
                // add user to the list of favorites
                self.favorites.append(favoritee)
                // add user to our set of users who are favorited
                self.favoritesSet.insert(favoritee.id)
            }}
        let failure: (AFDataResponse<APIData<Favorite>>) -> () = { (value) in
            self.alert = Alert(title: Text("Favorite Failed"),
                               message: Text("Failed to favorite this user, please try again"),
                               dismissButton: .default(Text("Close"), action: { self.showAlert = false }))
            self.showAlert = true
        }
        let req: Request = Request(method: .post, params: params, exten: FAVORITES, success: success, failure: failure)
        request(req: req)
    }
    
    //  check if a user is favorited by the current user
    //  :param userId (Int) - a user ID of the potential favoritee
    //  :return (Bool) true if userId is a favorite of the current user, false otherwise
    //  func isFavorite(userId: Int) -> Bool {
    //    for favorite in self.favorites {
    //      if (favorite.favoritee_id == userId) {
    //        return true
    //      }
    //    }
    //    return false
    //  }
    
    //  find a favorite object in self.favorites given favoriter and favoritee
    //  :param favoriterId (Int) - user ID of the favoriter
    //  :param favoriteeId (Int) - user ID of the favoritee
    //  :return (Favorite?) a Favorite object if a match is found, nil otherwise
    //  func findFavorite(favoriterId: Int, favoriteeId: Int) -> Favorite? {
    //    for favorite in self.favorites {
    //      if (favorite.favoriter_id == favoriterId && favorite.favoritee_id == favoriteeId) {
    //        return favorite
    //      }
    //    }
    //    return nil
    //  }
    
    // unfavorite another user
    // :param favoriteeId (Int) - user ID of the user being unfavorited
    // :return none
    func unfavorite(user: Users) {
        let id = user.favorite
        let params: [String : Any] = [:]
        let success: (AFDataResponse<APIData<Favorite>>) -> () = { (value) in
            if let _: APIData<Favorite> = value.value {
                self.refreshCurrentUser()
                user.favorite = -1
                self.favorites = self.favorites.filter { fav in fav.id != user.id }
                self.favoritesSet.remove(user.id)
            }}
        let failure: (AFDataResponse<APIData<Favorite>>) -> () = { (value) in
            self.alert = Alert(title: Text("Unfavorite Failed"),
                               message: Text("Failed to unfavorite this user, please try again"),
                               dismissButton: .default(Text("Close"), action: { self.showAlert = false }))
            self.showAlert = true
        }
        let req: Request = Request(method: .delete, params: params, exten: FAVORITES+"/"+String(id), success: success, failure: failure)
        request(req: req)
    }
    
    //
    // PLAYER FUNCTIONS
    //
    
    //  create a player
    //  :param status (String) - status of the player, can be "going", "maybe", "invited", or "not_going"
    //  :param userId (String) - user ID of the player
    //  :param gameId (String) - game ID of the player
    func createPlayer(status: String, userId: Int, gameId: Int) -> () {
        let params = [
            "status": status,
            "user_id": String(userId),
            "game_id": String(gameId)
        ]
        let success: (AFDataResponse<APIData<Player>>) -> () = { (value) in
            if let value: APIData<Player> = value.value {
                self.getGame(id: self.game.id)
                self.players.insert(value.data, at: 0)
                self.player = value.data
                
            }}
        let failure: (AFDataResponse<APIData<Player>>) -> () = { (value) in
            self.alert = Alert(title: Text("Create Player Failed"),
                               message: Text("Failed to add this user to this game, please try again"),
                               primaryButton: .default(
                                Text("Try Again"),
                                action: {
                                    self.createPlayer(status: status, userId: userId, gameId: gameId)
                                }
                               ),
                               secondaryButton: .default(
                                Text("Close"),
                                action: {
                                    self.showAlert = false
                                    self.alert = nil
                                }
                               )
            )
            self.showAlert = true
        }
        let req: Request = Request(method: .post, params: params, exten: PLAYERS, success: success, failure: failure)
        request(req: req)
    }
    
    //  invite a player to a game
    //  :param status (String) - status of the player, can be "going", "maybe", "invited", or "not_going"
    //  :param userId (String) - user ID of the player
    //  :param gameId (String) - game ID of the player
    func inviteUser(status: String, userId: Int, gameId: Int) -> () {
        let params = [
            "status": status,
            "user_id": String(userId),
            "game_id": String(gameId)
        ]
        let success: (AFDataResponse<APIData<Player>>) -> () = { (value) in
            if let value: APIData<Player> = value.value {
                self.getGame(id: self.game.id)
                self.players.insert(value.data, at: 0)
            }}
        let failure: (AFDataResponse<APIData<Player>>) -> () = { (value) in
            self.alert = Alert(title: Text("Create Player Failed"),
                               message: Text("Failed to add this user to this game, please try again"),
                               primaryButton: .default(
                                Text("Try Again"),
                                action: {
                                    self.createPlayer(status: status, userId: userId, gameId: gameId)
                                }
                               ),
                               secondaryButton: .default(
                                Text("Close"),
                                action: {
                                    self.showAlert = false
                                    self.alert = nil
                                }
                               )
            )
            self.showAlert = true
        }
        let req: Request = Request(method: .post, params: params, exten: PLAYERS, success: success, failure: failure)
        request(req: req)
    }
    
    
    // edit the status of a player belonging to the current user
    // :param playerId (Int) - ID of the player
    // :param status (String) - status of the player, can be "going", "maybe", "invited", "not_going", "I'm going", "I'm Invited", "I'm Maybe", or "I'm Not Going"
    // :return none
    func editPlayerStatus(playerId: Int, status: String) -> () {
        var s = ""
        if (status == "I'm Going") {
            s = "going"
        } else if (status == "I'm Invited") {
            s = "invited"
        } else if (status == "I'm Maybe") {
            s = "maybe"
        } else if (status == "I'm Not Going") {
            s = "not_going"
        } else {
            s = status
        }
        let params: Parameters = [
            "status": s
        ]
        let success: (AFDataResponse<APIData<Player>>) -> () = { (value) in
            if let value: APIData<Player> = value.value {
                self.getGame(id: self.game.id)
                self.refreshCurrentUser()
                self.player = value.data
            }}
        let failure: (AFDataResponse<APIData<Player>>) -> () = { (value) in
            self.alert = Alert(title: Text("Edit Player Status Failed"),
                               message: Text("Failed to edit the status of this player, please try again"),
                               primaryButton: .default(
                                Text("Try Again"),
                                action: {
                                    self.editPlayerStatus(playerId: playerId, status: status)
                                }
                               ),
                               secondaryButton: .default(
                                Text("Close"),
                                action: {
                                    self.showAlert = false
                                    self.alert = nil
                                }
                               )
            )
            self.showAlert = true
        }
        let req: Request = Request(method: .patch, params: params, exten: PLAYERS+"/"+String(playerId), success: success, failure: failure)
        request(req: req)
    }
    
    //  get all players of a specific status
    //  :param status (String) - status of a player, can be "going", "maybe", "invited", or "not_going"
    //  :return ([Player]) - an array of Player objects with the specified status
    func getPlayerWithStatus(status: Status) -> [Player] {
        var filteredResults: [Player] = [Player]()
        
        for player in self.players {
            if (player.status == status) {
                filteredResults.append(player)
            }
        }
        return filteredResults
    }
    
    //
    // MISC. FUNCTIONS
    //
    
    //  func fetchData() {
    //    login(username: "jxu", password: "secret")
    //  }
    
    // map a boolean to a list of users representing if they are favorited or not
    // :param users ([Users]) - list of the users
    // :return ([(User, Bool)]) - list of users with a tag for if they are favorited or not
    //  func forStatus(users: [Users]) -> [(user: Users, favorited: Bool)] {
    //    return users.map({ (user: $0, favorited: self.favoritesSet.contains($0.id)) }).sorted {
    //      switch ($0.favorited, $1.favorited) {
    //      case (true, _):
    //        return true
    //      case (_, true):
    //        return false
    //      default:
    //        return true
    //      }
    //    }
    //  }
    
    // map a boolean to the list of favorites representing if they are invited or not
    // :return ([(Favorite, Bool)]) - list of users with a tag for if they are invited or not
    //  func favoritesNotInvited() -> [(favorite: Favorite, invited: Bool)] {
    //    return self.favorites.map({ (favorite: $0, invited: self.gamePlayers.contains($0.user.data.id)) })
    //  }
    
    // search the database for users
    // :param query (String) - query to send to the database
    // :return none
    func searchUsers(query: String) {
        let params = [
            "query": query.lowercased()
        ]
        let success: (AFDataResponse<ListData<Users>>) -> () = { (value) in
            if let value: ListData<Users> = value.value {
                self.searchResults = value.data
            }
        }
        let failure: (AFDataResponse<ListData<Users>>) -> () = { (value) in }
        let req: Request = Request(method: .get, params: params, exten: SEARCH, success: success, failure: failure)
        request(req: req)
    }
    
    //  create an authorization header used in API requests
    //  :param token (String) - auth token of the current user
    //  :return none
    func createAuthHeader(token: String) {
        self.headers = [
            "Authorization": "Token " + token
        ]
    }
    
    //  create a alert with closing the alert as the dismissButton action
    //  :param title (String) - title of the alert
    //  :param message (String) - body message of the alert
    //  :param button (String) - text for the dismiss button
    func createAlert(title: String, message: String, button: String) -> Alert {
        return Alert(title: Text(title),
                     message: Text(message),
                     dismissButton: .default(
                        Text(button),
                        action: {
                            self.alert = nil
                        }
                     )
        )
    }
    
    //  loads contacts
    // :return none
    func fetchContacts() {
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactImageDataKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        do {
            try CNContactStore().enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                let newContact = Contact()
                newContact.firstName = contact.givenName
                newContact.lastName = contact.familyName
                newContact.phone = contact.phoneNumbers.first?.value
                if let uiImageNSData: NSData = contact.imageData as NSData? {
                    newContact.picture = Image(uiImage: UIImage(data: uiImageNSData as Data, scale: 1.0)!)
                }
                self.contacts.append(newContact)
            })
            self.contacts.sort()
        }
        catch {
            NSLog("[INFO] was unable to parse contacts")
        }
    }
    
    // filters the contacts based on a query
    // :param query (String) - the query to filter by
    // :return none
    func searchContacts(query: String) {
        if query == "" {
            self.contactsFiltered = self.contacts
        } else {
            let q = query.lowercased()
            let c = self.contacts
            self.contactsFiltered = c.filter({ $0.name().lowercased().contains(q) })
        }
    }
    
    func groupGames(games: [Game]) -> [Dictionary<String, [Game]>.Element] {
        let tempGames = games.sorted(by: { Helper.toTime(time: $0.time) < Helper.toTime(time: $1.time) })
        let games = Dictionary(grouping: tempGames, by: { $0.onDate() })
        let keys = games.sorted(by: { Helper.toDate(date: $0.key) < Helper.toDate(date: $1.key) })
        return keys
    }
}
