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
import AuthenticationServices

// test notification badge count
// show long address is short address is empty // fixed
// fix game not being focused on after creation // fixed
// change map pin name to name of game //
// fix changing status from invited games list details
// start migrating alert

struct Request<T> {
    let method: HTTPMethod
    let params: Parameters
    let exten: String
    let success: ((AFDataResponse<T>) -> ())
    let failure: ((AFDataResponse<T>) -> ())
}

class ViewModel: NSObject, ObservableObject {
    
    let appDelegate: AppDelegate = AppDelegate()
    
    @Published var notificationCenter: NotificationCenter = NotificationCenter()
    
    // list of all games
    @Published var games: [Game] = [Game]()
    // games the user has affiliation with
    @Published var userGames: [Game] = [Game]()
    // affiliated games grouped by date for display in home table
    @Published var affiliatedGamesGrouped: [GenericGameGroup] = [GenericGameGroup]()
    // invited games grouped by date for display in invited games list
    @Published var invitedGamesGrouped: [GenericGameGroup] = [GenericGameGroup]()
    
    @Published var focusOnGame: Bool = false
    @Published var isOpen: Bool = false
    
    @Published var landingLink: String? = nil
    
    @Published var user: User = genericCurrentUser
    @Published var potentialUser: PotentialUser = genericPotentialUser
    //    @Published var profilePic: Image = Image(String)
    // games the user is invited to
    @Published var invitedGames: [Game] = [Game]()
    @Published var groupedGames: [GenericGameGroup] = [GenericGameGroup]()
    
    // set of user identifications who are favorited by the current user
    @Published var favoritesSet: Set<Int> = Set()
    // users who have favorited the user but have not been favorited
    @Published var favoriteesNotFavorited: [Users] = [Users]()
    
    @Published var userId: Int?
    var password: String = "secret"
    var headers: HTTPHeaders?
    
    @Published var sharingContent: Bool = false
    @Published var editingProfile: Bool = false
    @Published var showingDiscoverFavorites: Bool = false
    @Published var showingMyFavorites: Bool = false
    
    @Published var game: Game = Game(id: -1, name: "Generic Game", date: "2021-05-15", time: "2000-01-01 14:50:19", desc: "", priv: true, longitude: -79.94456661125692,   latitude: 40.441405662286684, invited: [Users](), maybe: [Users](), going: [Users](), player: Player(id: -1, status: Status.going), shortAddress: "5700 Wilkins Ave", longAddress: "5700 Wilkins Avenue, Pittsburgh, PA")
    
    @Published var gamePlayers: Set<Int> = Set()
    
    @Published var userLocation = Location()
    // used when the user changes authorization for their location to refocus map
    @Published var reFocusUser: Bool = false
    
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
    @Published var selectedLocation: MKMapItem = MKMapItem()
    
    @Published var contacts: [Contact] = [Contact]()
    @Published var contactsFiltered: [Contact] = [Contact]()
    @Published var contact: Contact?
    
    @Published var inviteMessage: String = "Add me at username {USER_NAME} on GotNext! Sign up and let's start hooping: \(APPLINK)"
    
    var response: UNNotificationResponse?
    var presentationOptions: UNNotificationPresentationOptions = [.badge, .sound]
    
    var secureStoreWithGenericPwd: SecureStore!
    
    override init() {
        super.init()
        userLocation.locationManager.delegate = self
        UNUserNotificationCenter.current().delegate = self
    }
    
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
                self.refreshCurrentUser()
            }}
        let failure: (AFDataResponse<APIData<User>>) -> () = { (value) in
            print("[INFO] could not send contacts")
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
    
    func saveToken(token: String, id: Int) -> () {
        let genericPwdQueryable = GenericPasswordQueryable(service: "MyService")
        self.secureStoreWithGenericPwd = SecureStore(secureStoreQueryable: genericPwdQueryable)
        let credentials: String = token + ":" + String(id)
        do {
            try self.secureStoreWithGenericPwd.setValue(credentials, for: "token")
        } catch (let e) { print("[INFO] could not save password with \(e.localizedDescription)") }
    }
    
    //
    // USER FUNCTIONS
    //
    
    func handleAuthorization(result: (Result<ASAuthorization, Error>)) -> () {
        switch result {
        case .success(let authorization):
            // handle autorization
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userId = appleIDCredential.user
                let identityToken = appleIDCredential.identityToken
                let authCode = appleIDCredential.authorizationCode
                let email = appleIDCredential.email
                let givenName = appleIDCredential.fullName?.givenName
                let familyName = appleIDCredential.fullName?.familyName
                let state = appleIDCredential.state
                let params: Parameters = [
                    "firstname": givenName ?? "firstname",
                    "lastname": familyName ?? "lastname",
                    "user_id": userId,
                    "identity_token": identityToken!,
                    "auth_code": authCode!,
                    "email": email ?? "email@gmail.com",
                    "state": state as Any
                ]
                self.potentialUser = PotentialUser(userId: appleIDCredential.user, identityToken: appleIDCredential.identityToken, authCode: appleIDCredential.authorizationCode, email: appleIDCredential.email, givenName: appleIDCredential.fullName?.givenName, familyName: appleIDCredential.fullName?.familyName, state: appleIDCredential.state)
                AF.request(ADDRESS + APPLE_AUTHENTICATE, method: .post, parameters: params)
                    .validate()
                    .responseDecodable {
                        ( response: AFDataResponse<ListData<UserLogin>>) in
                        switch response.result {
                        case .success:
                            if let value: ListData<UserLogin> = response.value {
                                // user already exists in the system
                                if let userLogin = value.data.first {
                                    let token = userLogin.api_key
                                    let user_id = userLogin.id
                                    self.userId = user_id
                                    print("[INFO] successfully received user with token \(token) and identification \(user_id)")
                                    // save key to keychain
                                    let genericPwdQueryable = GenericPasswordQueryable(service: "MyService")
                                    self.secureStoreWithGenericPwd = SecureStore(secureStoreQueryable: genericPwdQueryable)
                                    let credentials: String = token + ":" + String(user_id)
                                    do {
                                        try self.secureStoreWithGenericPwd.setValue(credentials, for: "token")
                                    } catch (let e) { print("[INFO] could not save password with \(e.localizedDescription)") }
                                    // refresh data
                                    self.createAuthHeader(token: token)
                                    self.refreshCurrentUser()
                                    self.getGames()
                                    self.currentScreen = Page.app
                                }
                                // user does not yet exist in the system
                                else {
                                    // redirect to additional information page
                                    //                                    self.currentScreen = Page.additionalInformation
                                    self.landingLink = "additionalInformation"
                                }
                            }
                        case .failure:
                            print("[INFO] could not authenticate")
                        }
                    }
            }
        case .failure(let error):
            print("Authorization failed: \(error.localizedDescription)")
        }
    }
    
    // checks to see if prior credentials were stored in the keychain
    func tryAppleLogin() {
        let genericPwdQueryable = GenericPasswordQueryable(service: "MyService")
        secureStoreWithGenericPwd = SecureStore(secureStoreQueryable: genericPwdQueryable)
        do {
            let credentials = try secureStoreWithGenericPwd.getValue(for: "token")
            if let components = credentials?.components(separatedBy: ":") {
                let token = components.first ?? ""
                let user_id = components.last ?? ""
                self.userId = Int(user_id)
                self.createAuthHeader(token: token)
                self.refreshCurrentUser()
                self.getGames()
                self.currentScreen = Page.app
            }
        } catch (let e) { print("[INFO] could not get password with \(e.localizedDescription)") }
    }
    
    // checks to see if prior credentials were stored in the keychain
    func tryLogin() {
        let genericPwdQueryable = GenericPasswordQueryable(service: "MyService")
        secureStoreWithGenericPwd = SecureStore(secureStoreQueryable: genericPwdQueryable)
        do {
            let credentials = try secureStoreWithGenericPwd.getValue(for: "genericPassword")
            if let components = credentials?.components(separatedBy: ":") {
                login(username: components.first ?? "", password: components.last ?? "")
            }
        } catch (let e) { print("[INFO] could not get password with \(e.localizedDescription)") }
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
                        self.password = password
                        self.createAuthHeader(token: token)
                        self.refreshCurrentUser()
                        self.getGames()
                        //                        self.fetchContacts()
                        self.currentScreen = Page.app
                    }
                case .failure:
                    print("[INFO] \(response)")
                    self.currentScreen = Page.landing
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
            print("[INFO[ could not remove password with \(e.localizedDescription)")
        }
        do {
            try secureStoreWithGenericPwd.removeValue(for: "token")
        } catch (let e) {
            print("[INFO[ could not remove token with \(e.localizedDescription)")
        }
        
        self.games = [Game]()
        self.favoritesSet = Set()
        self.userId = nil
        self.headers = nil
        self.gamePlayers = Set()
        self.userLocation = Location()
        self.currentScreen = Page.landing
        self.currentTab = Tab.home
        self.isOpen = false
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
            if let value: APIData<User> = response.value {
                print("[INFO] successfully fetched user \(value.data.username)")
                self.user = value.data
                self.inviteMessage = "Add me at \(self.user.username) on GotNext! Sign up and let's start hooping"
                
                self.favoritesSet = Set(value.data.favorites.map { $0.id })
                self.favoriteesNotFavorited = self.user.favoritees.filter { $0.favorite == -1 }
                //                self.favoriteesNotFavorited = self.user.favoritees.filter { !self.favoritesSet.contains($0.id) }
                //                self.favoriteesNotFavorited = self.user.favoritees.filter { !self.user.favorites.contains($0) }
                
                self.potentials = value.data.potentials.filter { $0.favorite == -1 && !self.favoriteesNotFavorited.contains($0)}
                self.contactPotentials = value.data.contacts
            } else {
                print("[INFO] could not get user with \(response)")
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
    
    //  create a new user
    //  :param potentialUser (PotentialUser) - potential user class
    func createPotentialUser(potentialUser: PotentialUser) -> () {
        let acceptableDate = Helper.toAcceptableDate(date: potentialUser.dob)
        let params = [
            "firstname": potentialUser.givenName,
            "lastname": potentialUser.familyName,
            "email": potentialUser.email,
            "dob": acceptableDate,
            "phone": potentialUser.phone,
            "apple": potentialUser.userId
        ]
        let success: (AFDataResponse<APIData<UserLogin>>) -> () = { (value) in
            if let value: APIData<UserLogin> = value.value {
                let token = value.data.api_key
                let user_id = value.data.id
                self.userId = user_id
                print("[INFO] successfully received user with token \(token) and identification \(user_id)")
                // save key to keychain
                let genericPwdQueryable = GenericPasswordQueryable(service: "MyService")
                self.secureStoreWithGenericPwd = SecureStore(secureStoreQueryable: genericPwdQueryable)
                let credentials: String = token + ":" + String(user_id)
                do {
                    try self.secureStoreWithGenericPwd.setValue(credentials, for: "token")
                } catch (let e) { print("[INFO] could not save password with \(e.localizedDescription)") }
                // refresh data
                self.createAuthHeader(token: token)
                self.refreshCurrentUser()
                self.getGames()
                self.landingLink = nil
                self.currentScreen = Page.app
            }}
        let failure: (AFDataResponse<APIData<UserLogin>>) -> () = { (value) in
            self.alert = self.createAlert(title: "Invalid Profile Information",
                                          message: "The profile information you entered was invalid, please check your inputs and try again",
                                          button: "Got it")
            self.showAlert = true
        }
        let req: Request = Request(method: .post, params: params, exten: CREATE_USER, success: success, failure: failure)
        AF.request(ADDRESS + req.exten, method: req.method, parameters: req.params)
            .validate()
            .responseDecodable {
                ( response: AFDataResponse<APIData<UserLogin>>) in
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
    func editCurrentUser(user: User, image: UIImage?) -> () {
        var params: [String : Any]
        if let encoding: String = image?.jpegData(compressionQuality: 0.7)?.base64EncodedString() {
            params = [
                "firstname": user.firstName,
                "lastname": user.lastName,
                "username": self.user.username,
                "email": user.email,
                "dob": self.user.dob,
                "phone": user.phone,
                "image": ["data": "data:image/jpeg;base64,[\(encoding)]"],
                //                "password": password,
                //                "password_confirmation": password
            ]
        } else {
            params = [
                "firstname": user.firstName,
                "lastname": user.lastName,
                "username": self.user.username,
                "email": user.email,
                "dob": self.user.dob,
                "phone": user.phone,
                //                "password": password,
                //                "password_confirmation": password
            ]
        }
        let success: (AFDataResponse<APIData<User>>) -> () = { (value) in
            if let value: APIData<User> = value.value {
                self.user = value.data
                self.editingProfile = false
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
    
    //    func setLocation() -> () {
    //        self.currentTab = Tab.home
    //        self.showingCover = false
    //        self.settingLocation = true
    //    }
    
    //
    // GAME FUNCTIONS
    //
    
    //  get all games
    //  :param none
    //  :return none
    func getGames() {
        let params: Parameters = [
            "user_id": self.userId!
        ]
        let success: (AFDataResponse<ListData<Game>>) -> () = { (value) in
            if let value: ListData<Game> = value.value {
                self.games = value.data
                self.userGames = value.data.filter { $0.player.status.isAffiliated }
                self.affiliatedGamesGrouped = self.groupGenericGameGroups(games: self.userGames)
                self.invitedGamesGrouped = self.groupGenericGameGroups(games: self.userGames.filter { $0.player.status == .invited })
                print("[INFO] successfully fetched \(self.games.count) games, \(self.userGames.count) user games, and \(self.affiliatedGamesGrouped.count) affiliated user game groups")
            }}
        let failure: (AFDataResponse<ListData<Game>>) -> () = { (value) in }
        let req: Request = Request(method: .get, params: params, exten: GET_GAMES, success: success, failure: failure)
        request(req: req)
    }
    
    //  get a game by identification
    //  id (Int) - the identification for a game
    //  return (none)
    func getGame(id: Int) -> () {
        let success: (AFDataResponse<APIData<Game>>) -> () = { (value) in
            if let value: APIData<Game> = value.value {
                print("[INFO] successfully retrieved game \(value.data.name) with identification \(value.data.id)")
                self.game = value.data
            }}
        let failure: (AFDataResponse<APIData<Game>>) -> () = { (value) in print("[INFO] could not game with identification \(id)") }
        let req: Request = Request(method: .get, params: [:], exten: GAMES+"/"+String(id), success: success, failure: failure)
        request(req: req)
    }
    
    func localUpdateGames() -> () {
        print("[INFO] updating local games")
        self.games = self.games.filter { $0.id != self.game.id }
        print("[INFO] filtered game with identification \(game.id)")
        self.games.append(self.game)
        self.userGames = self.games.filter { $0.player.status.isAffiliated }
        self.affiliatedGamesGrouped = self.groupGenericGameGroups(games: self.userGames)
        self.invitedGamesGrouped = self.groupGenericGameGroups(games: self.userGames.filter { $0.player.status == .invited })
    }
    
    //  create a new game
    //  :param name (String) - name of the game court
    //  :date (Date) - date and time of the game
    //  :description (String) - description of the game
    //  :priv (Bool) - whether the game is private
    //  :latitude (Double) - latitude of the game location
    //  :longitude: (Double) - longitude of the game location
    //  :return (Game?) - the game object if created successfully, nil otherwise
    func createGame(name: String, date: Date, description: String, priv: Bool, latitude: Double, longitude: Double, shortAddress: String, longAddress: String) -> () {
        let acceptableDate = Helper.toAcceptableDate(date: date)
        let params: Parameters = [
            "name": name,
            "date": acceptableDate,
            "time": acceptableDate,
            "description": description,
            "private": priv,
            "longitude": longitude,
            "latitude": latitude,
            "shortAddress": shortAddress.isEmpty ? longAddress : shortAddress,
            "longAddress": longAddress
        ]
        let success: (AFDataResponse<APIData<Game>>) -> () = { (value) in
            if let value: APIData<Game> = value.value {
                print("[INFO] successfully created a game with name \(value.data.name)")
                self.game = value.data
                print("[INFO] successfully set new game and now focus on game")
                self.focusOnGame = true
                // create a player for our new game
                let user: Users = Users(id: self.user.id, username: self.user.username, email: self.user.email, firstName: self.user.firstName, lastName: self.user.lastName, dob: self.user.dob, phone: self.user.phone, favorite: -1, profilePicture: self.user.profilePicture)
                self.createPlayer(status: Status.going, user: user, game: self.game)
                // add the new game to our list of games
                self.games.append(value.data)
                // add game to our user games
                //                self.userGames.append(value.data)
                // update game groupings
                //                self.affiliatedGamesGrouped = self.groupGenericGameGroups(games: self.userGames)
                // dismiss any covers or links displaying creating a game and toggle modal down
                self.showingCover = false
                self.isOpen = false
            }
        }
        let failure: (AFDataResponse<APIData<Game>>) -> () = { (value) in
            self.alert = Alert(title: Text("Create Game Failed"),
                               message: Text("Failed to create this game, please try again"),
                               dismissButton: .default(Text("Close"), action: { self.showAlert = false }))
            self.showAlert = true }
        let req: Request = Request(method: .post, params: params, exten: GAMES, success: success, failure: failure)
        self.focusOnGame = true
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
        self.getGame(id: game.id)
        //        self.game = game
        self.showDetails()
    }
    
    func showGameByIdentification(id: Int) -> () {
        self.getGame(id: id)
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
                // add favorite object identification to favoritee user
                favoritee.favorite = favorite.data.id
                print(favoritee.displayName())
                print(favoritee.favorite)
                // add user to the list of favorites
                self.user.favorites.append(favoritee)
                // add user to our set of users who are favorited
                self.favoritesSet.insert(favoritee.id)
                // refresh relevant lists
                //                self.favoriteesNotFavorited = self.user.favoritees.filter { !self.favoritesSet.contains($0.id) }
                //                self.potentials = self.user.potentials.filter { $0.favorite == -1 && !self.favoriteesNotFavorited.contains($0)}
            }}
        let failure: (AFDataResponse<APIData<Favorite>>) -> () = { (value) in
            self.alert = Alert(title: Text("Favorite Failed"),
                               message: Text("Failed to favorite this user, please try again"),
                               dismissButton: .default(Text("Close"), action: { self.showAlert = false }))
            self.showAlert = true
        }
        let req: Request = Request(method: .post, params: params, exten: FAVORITES, success: success, failure: failure)
        refreshCurrentUser()
        request(req: req)
    }
    
    // unfavorite another user
    // :param favoriteeId (Int) - user ID of the user being unfavorited
    // :return none
    func unfavorite(user: Users) {
        let id = user.favorite
        let params: [String : Any] = [:]
        let success: (AFDataResponse<APIData<Favorite>>) -> () = { (value) in
            if let _: APIData<Favorite> = value.value {
                // remove favorite object identification from favoritee user
                user.favorite = -1
                // remove user to the list of favorites
                self.user.favorites = self.user.favorites.filter { fav in fav.id != user.id }
                // remove user from our set of users who are favorited
                self.favoritesSet.remove(user.id)
                // refresh relevant lists
                //                self.favoriteesNotFavorited = self.user.favoritees.filter { !self.favoritesSet.contains($0.id) }
                //                self.potentials = self.user.potentials.filter { $0.favorite == -1 && !self.favoriteesNotFavorited.contains($0)}
            }}
        let failure: (AFDataResponse<APIData<Favorite>>) -> () = { (value) in
            self.alert = Alert(title: Text("Unfavorite Failed"),
                               message: Text("Failed to unfavorite this user, please try again"),
                               dismissButton: .default(Text("Close"), action: { self.showAlert = false }))
            self.showAlert = true
        }
        let req: Request = Request(method: .delete, params: params, exten: FAVORITES+"/"+String(id), success: success, failure: failure)
        refreshCurrentUser()
        request(req: req)
    }
    
    //
    // PLAYER FUNCTIONS
    //
    
    //  create a player
    //  :param status (Status) - status of the player
    //  :param userId (String) - user ID of the player
    //  :param gameId (String) - game ID of the player
    func createPlayer(status: Status, user: Users, game: Game) -> () {
        let params: Parameters = [
            "status": status.encoding,
            "user_id": String(user.id),
            "game_id": String(game.id)
        ]
        let success: (AFDataResponse<APIData<Player>>) -> () = { (value) in
            if let value: APIData<Player> = value.value {
                // add user to the game for the status specified
                game.addUser(status: status, user: user)
                // if this is for the current user, add player to game
                if user.id == self.user.id {
                    game.player = value.data
                    self.localUpdateGames()
                    // add to list of user games
                    //                    self.userGames.append(game)
                    // update groupings
                    //                    self.affiliatedGamesGrouped = self.groupGenericGameGroups(games: self.userGames)
                }
                self.game = game
            }}
        let failure: (AFDataResponse<APIData<Player>>) -> () = { (value) in
            //            self.alert = Alert(title: Text("Update Status Failed"),
            //                               message: Text("Failed to update status"),
            //                               dismissButton: .default(Text("Close"), action: { self.showAlert = false }))
            //            self.showAlert = true
        }
        let req: Request = Request(method: .post, params: params, exten: PLAYERS, success: success, failure: failure)
        request(req: req)
    }
    
    //  invite a player to a game
    //  :param status (String) - status of the player
    //  :param userId (String) - user ID of the player
    //  :param gameId (String) - game ID of the player
    //    func inviteUser(status: Status, userId: Int, gameId: Int) -> () {
    //        let params: Parameters = [
    //            "status": status.encoding,
    //            "user_id": String(userId),
    //            "game_id": String(gameId)
    //        ]
    //        let success: (AFDataResponse<APIData<Player>>) -> () = { (value) in
    //            if let value: APIData<Player> = value.value {
    //                self.getGame(id: self.game.id)
    //            }}
    //        let failure: (AFDataResponse<APIData<Player>>) -> () = { (value) in
    //            self.alert = Alert(title: Text("Invite Player Failed"),
    //                               message: Text("Failed to invite this user to this game, please try again"),
    //                               dismissButton: .default(Text("Close"), action: { self.showAlert = false }))
    //            self.showAlert = true
    //        }
    //        let req: Request = Request(method: .post, params: params, exten: PLAYERS, success: success, failure: failure)
    //        request(req: req)
    //    }
    
    
    // edit the status of a player belonging to the current user
    // :param id (Int) - ID of the player
    // :param status (Status) - status of the player
    // :return none
    func editPlayerStatus(currStatus: Status, newStatus: Status, user: User, game: Game) -> () {
        let params: Parameters = [
            "status": newStatus.encoding
        ]
        let success: (AFDataResponse<APIData<Player>>) -> () = { (value) in
            if let _: APIData<Player> = value.value {
                print("[INFO] successfully updated player status")
                let simpleUser: Users = Users(id: self.user.id, username: self.user.username, email: self.user.email, firstName: self.user.firstName, lastName: self.user.lastName, dob: self.user.dob, phone: self.user.phone, favorite: -1, profilePicture: self.user.profilePicture)
                game.switchUser(currStatus: currStatus, newStatus: newStatus, user: simpleUser)
                print("[INFO] switched user for game \(game.id) from \(currStatus) to \(newStatus)")
                self.game = game
                self.localUpdateGames()
            }}
        let failure: (AFDataResponse<APIData<Player>>) -> () = { (value) in
            //            self.alert = Alert(title: Text("Edit Player Status Failed"),
            //                               message: Text("Failed to edit the status of this player, please try again"),
            //                               dismissButton: .default(Text("Close"), action: { self.showAlert = false }))
            //            self.showAlert = true
        }
        let req: Request = Request(method: .patch, params: params, exten: PLAYERS+"/"+String(game.player.id), success: success, failure: failure)
        request(req: req)
    }
    
    func invite(user: Users, game: Game) -> () {
        print("[INFO] inviting user \(user.username) to game \(game.name)")
        self.createPlayer(status: Status.invited, user: user, game: game)
    }
    
    func sortUsersUtility(lhs: Users, rhs: Users) -> Bool {
        if lhs.id == self.user.id { return true }
        if rhs.id == self.user.id { return false }
        if lhs.favorite > -1 && rhs.favorite == -1 { return true }
        if lhs.favorite == -1 && rhs.favorite > -1 { return false }
        return lhs.displayName() < rhs.displayName()
    }
    
    func sortUsers(users: [Users]) -> [Users] {
        return users.sorted(by: sortUsersUtility)
    }
    
    func updateStatus(game: Game, currStatus: Status, newStatus: Status) -> () {
        let player: Player = game.player
        if player.id != -1 { // player exists on the server
            self.editPlayerStatus(currStatus: currStatus, newStatus: newStatus, user: user, game: game)
        } else { // must create a player instance on the server
            let user: Users = Users(id: self.user.id, username: self.user.username, email: self.user.email, firstName: self.user.firstName, lastName: self.user.lastName, dob: self.user.dob, phone: self.user.phone, favorite: -1, profilePicture: self.user.profilePicture)
            self.createPlayer(status: newStatus, user: user, game: game)
        }
        //        self.localUpdateGames()
    }
    
    //
    // MISC. FUNCTIONS
    //
    
    // search the database for users
    // :param query (String) - query to send to the database
    // :return none
    func searchUsers(query: String) -> () {
        if query.isEmpty {
            self.searchResults.removeAll()
            return
        }
        let params = ["query": query.lowercased()]
        let success: (AFDataResponse<ListData<Users>>) -> () = { (value) in
            if let value: ListData<Users> = value.value {
                print("[INFO] successfully retrieved search results of \(value.data.count) users")
                self.searchResults = value.data.filter { !self.user.favorites.contains($0) }
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
    
    func requestContactAccess() -> () {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .notDetermined:
            CNContactStore().requestAccess(for: .contacts) { access, error in
                if access {
                    print("[INFO] user has just granted access to their contacts")
                    DispatchQueue.main.async {
                        self.fetchContacts()
                    }
                }
            }
            break
        case .denied:
            break
        case .restricted:
            break
        case .authorized:
            break
        @unknown default:
            break
        }
    }
    
    // loads contacts
    // :param none
    // :return none
    func fetchContacts() -> () {
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
            self.sendContacts()
        }
        catch {
            NSLog("[INFO] was unable to parse contacts")
        }
    }
    
    // filters the contacts based on a query
    // :param query (String) - the query to filter by
    // :return none
    func searchContacts(query: String) -> () {
        if query == "" {
            self.contactsFiltered = self.contacts
        } else {
            let q = query.lowercased()
            let c = self.contacts
            self.contactsFiltered = c.filter({ $0.name().lowercased().contains(q) })
        }
    }
    
    func groupGenericGameGroups(games: [Game]) -> [GenericGameGroup] {
        let tempGames = games.sorted(by: { $0.date < $1.date })
        let games = Dictionary(grouping: tempGames, by: { Helper.getDateTimeProp(dateTime: $0.date, prop: "YYYY-MM-dd") })
        let genericGameGroups: [GenericGameGroup] = games.map { key, value in GenericGameGroup(date: key, games: value) }
        return genericGameGroups.sorted()
    }
    
    func activityItems(game: Game) -> [Any] {
        var items = [Any]()
        let message: String = "I'm inviting you to \(game.name). Go to the app or download GotNext to reserve your spot and see who else is coming!"
        let URLString = "https://maps.apple.com?ll=\(game.latitude),\(game.longitude)&q=\(game.name)"
        
        if let url = NSURL(string: URLString) {
            items.append(url)
        }
        let locationVCardString = [
            "BEGIN:VCARD",
            "VERSION:3.0",
            "PRODID:-//Joseph Duffy//Blog Post Example//EN",
            "N:;Shared Location;;;",
            "FN:Shared Location",
            "item1.URL;type=pref:\(URLString)",
            "item1.X-ABLabel:map url",
            "END:VCARD"
        ].joined(separator: "\n")
        guard let vCardData : NSSecureCoding = locationVCardString.data(using: .utf8) as NSSecureCoding? else { return items }
        let vCardActivity = NSItemProvider(item: vCardData, typeIdentifier: "UTTypeVCard")
        items.append(vCardActivity)
        items.append(message)
        
        //        if let app = NSURL(string: APPLINK) {
        //            items.append(app)
        //        }
        //        let appLocationVCardString = [
        //            "BEGIN:VCARD",
        //            "VERSION:3.0",
        //            "PRODID:-//Joseph Duffy//Blog Post Example//EN",
        //            "N:;Shared Location;;;",
        //            "FN:Shared Location",
        //            "item1.URL;type=pref:\(APPLINK)",
        //            "item1.X-ABLabel:url",
        //            "END:VCARD"
        //        ].joined(separator: "\n")
        //
        //        guard let appVCardData : NSSecureCoding = appLocationVCardString.data(using: .utf8) as NSSecureCoding? else { return items }
        //        let appVCardActivity = NSItemProvider(item: appVCardData, typeIdentifier: "UTTypeVCard")
        //        items.append(appVCardActivity)
        
        //        items.append(".\(APPLINK).")
        
        return items
    }
    
    func createDevice() -> () {
        let completion: (AFDataResponse<Int>) -> () = { response in
            switch response.result {
            case .success:
                print("[INFO] successfully created token")
            case .failure:
                print("[INFO] could not create token with \(response)")
            }
        }
        //        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let token = AppDelegate.token
        APIService.createDevice(user_id: self.userId!, token: token!, completion: completion, headers: self.headers)
    }
    
    func saveToken() -> () {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0].stringByAppendingPathComponent(aPath: "Token.plist")
        let archiver = NSKeyedArchiver(requiringSecureCoding: true)
        archiver.encode("41bac9bb10cedcee8469d83d8388257513a12bd8e5b79126c11829013c1e719e", forKey: "token")
        archiver.finishEncoding()
        //        archiver.encodedData.write(to: URL(string: path)!)
        print("[INFO] successfully wrote token to file \(path)")
    }
    
    func loadToken() -> () {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0].stringByAppendingPathComponent(aPath: "Token.plist")
        if FileManager.default.fileExists(atPath: path) {
            if let data = NSData(contentsOfFile: path) {
                do {
                    let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data as Data)
                    let token = unarchiver.decodeDouble(forKey: "token")
                    unarchiver.finishDecoding()
                    print("[INFO] found token \(token)]")
                }
                catch { print("[INFO] cannot read data")}
            } else {
                print("[INFO] file not found at path \(path)")
            }
        }
    }
}

extension ViewModel: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            break
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            print("[INFO] user has authorized access to their location")
            self.reFocusUser = true
        case .authorizedAlways:
            print("[INFO] user has authorized access to their location always")
            self.reFocusUser = true
        case .authorizedWhenInUse:
            print("[INFO] user has authorized access to their location when in use")
            self.reFocusUser = true
        @unknown default:
            break
        }
    }
}

extension ViewModel: UNUserNotificationCenterDelegate  {
    
    // asks the delegate to process the user's response to a delivered notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("[INFO] received a notification while the app is in the foreground")
        // silence notifications when the app is in the foreground
        presentationOptions = []
        completionHandler(presentationOptions)
    }
    
    // asks the delegate how to handle a notification that arrived while the app was running in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // get our initial app data
        self.refreshCurrentUser()
        self.getGames()
        self.response = response
        let notification: UNNotification = response.notification
        let request: UNNotificationRequest = notification.request
        let content: UNNotificationContent = request.content
        // custom data included from server
        let userInfo: [AnyHashable: Any] = content.userInfo
        let type: String = userInfo["type"] as! String
        let userData: [String: Any] = userInfo["data"] as! [String : Any]
        switch type {
        case "invite":
            // game identification from invite
            let id: Int = Int(userData["game_id"] as! String)!
            // switch to home tab
            self.currentTab = .home
            // display the game
            self.showGameByIdentification(id: id)
        case "favorite":
            // switch tab to profile
            self.currentTab = .profile
            // boolean for if user favorited yet
            let favorited: Bool = userData["favorited"] as! Bool
            // current user already favorited so show their friends
            if favorited {
                self.showingMyFavorites = true
            } else { // show discover friends
                self.showingDiscoverFavorites = true
            }
        default:
            break
        }
        
        completionHandler()
    }
    
    // asks the delegate to display the in-app notification settings
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) { }
}
