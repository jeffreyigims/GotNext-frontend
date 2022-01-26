import UIKit
import Alamofire
import Foundation

struct Users: Decodable {
  let id: Int
  let username: String
  let email: String
  let firstName: String
  let lastName: String
  let dob: String
  let phone: String
  enum CodingKeys: String, CodingKey {
    case id
    case username
    case email
    case firstName = "firstname"
    case lastName = "lastname"
    case dob
    case phone
  }
}

struct Games: Decodable, Encodable, Identifiable {
  let id: Int
  let name: String
  let date: String
  let time: String
  let description: String
  let priv: Bool
  let longitude: Double
  let latitude: Double
  enum CodingKeys: String, CodingKey {
    case id
    case name
    case date
    case time
    case description
    case priv = "private"
    case longitude
    case latitude
  }
}

struct Player: Decodable, Identifiable {
  let id: Int
//  let userId: Int
  let status: String
  let game: APIData<Games>
  enum CodingKeys: String, CodingKey {
    case id
    case status
//    case userId = "user_id"
    case game
  }
}

struct Favorite: Decodable {
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

struct User: Decodable {
  let id: Int
  let username: String
  let email: String
  let firstName: String
  let lastName: String
  let dob: String
  let phone: String
  let players: [APIData<Player>]
  let favorites: [APIData<Favorite>]
  enum CodingKeys: String, CodingKey {
    case id
    case username
    case email
    case firstName = "firstname"
    case lastName = "lastname"
    case dob
    case phone
    case players
    case favorites
  }
}

struct Game: Decodable {
  let id: Int
  let name: String
  let date: String
  let time: String
  let description: String
  let priv: Bool
  let longitude: Double
  let latitude: Double
  let invited: [APIData<Users>]
  let maybe: [APIData<Users>]
  let going: [APIData<Users>]
  enum CodingKeys: String, CodingKey {
    case id
    case name
    case date
    case time
    case description
    case priv = "private"
    case longitude
    case latitude
    case invited
    case maybe
    case going
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

struct ListData<T>: Decodable where T: Decodable {
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

struct APIData<T>: Decodable where T: Decodable {
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
}

func login(username: String, password: String) -> String? {
  let credentials: String = username + ":" + password
  let encodedCredentials: String = Data(credentials.utf8).base64EncodedString()

  let headers: HTTPHeaders = [
    "Authorization": "Basic " + encodedCredentials
  ]
  
  var auth: String?
  AF.request("http://secure-hollows-77457.herokuapp.com/token/", headers: headers).responseDecodable {
    ( response: AFDataResponse<UserLogin> ) in
    if let value: UserLogin = response.value {
      debugPrint("success")
      print(value.api_key)
      auth = value.api_key
    }
  }
  print(auth)
  return auth
}

let headers: HTTPHeaders = [
  "Authorization": "Token " + "37935062f0b281fe9e36a08727680363"
]

//  refresh the current user by updating self.user
//  :param none
//  :return none
func refreshCurrentUser() {
  let request = "http://secure-hollows-77457.herokuapp.com/users/" + String(1)
  AF.request(request, headers: headers).responseDecodable { ( response: AFDataResponse<APIData<User>> ) in
    if let value: APIData<User> = response.value {
      print(value.data)
    }
  }
  
//  AF.request("http://secure-hollows-77457.herokuapp.com/games", headers: headers).responseDecodable { ( response: AFDataResponse<ListData<Games>> ) in
//    if let value: ListData<Games> = response.value {
//      print(value.data)
//    }
//  }
  
//   this proves that the request is returning successfully
//  AF.request(request, headers: headers).response{ response in
//    debugPrint(response)
//  }
}

//print(refreshCurrentUser())

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

//let data =
//  """
//{
//  "data": {
//    "id": "4",
//    "type": "users",
//    "attributes": {
//      "id": 4,
//      "username": "jigims",
//      "email": "",
//      "firstname": "",
//      "lastname": "",
//      "dob": "",
//      "phone": ""
//    }
//  }
//}
//""".data(using: .utf8)
//
//let decoder = JSONDecoder()
//let f = try decoder.decode(APIData<Users>.self, from: data!)
//let favorite = Favorite(id: 4, favoriter_id: 3, favoritee_id: 4, user: f)
//print(favorite)
let data =
"""
{
  "id":2,
  "status":"going",
  "game":
  {"data":
    {"id":"2","type":"game","attributes":
      {"id":2,
        "name":"game2",
        "date":"2020-10-29",
        "time":"2000-01-01T13:16:43.000Z",
        "description":"test description",
        "private":false,
        "longitude":0.0,
        "latitude":0.0,
        "invited": [],
        "mabybe": [],
        "going": []
      }
    }
  }
}
""".data(using: .utf8)
let decoder = JSONDecoder()
let p = try decoder.decode(Player.self, from: data!)
let g = try decoder.decode(Player.self, from: data!)
print(p)

//
//let j = Bundle.main.decode([Player].self, from: "players.json").first
//let i = Bundle.main.decode([Player].self, from: "players.json").first
//print(j)

class Parser {

  let urlString = "https://api.spoonacular.com/recipes/random?limitLicense=true&number=10&apiKey=2b7dcfdef8604d26a562d6c6963dc969"

  func fetchRepositories(completionHandler: @escaping ([Recipe]) -> Void) {
    AF.request(self.urlString).responseDecodable(of: Recipes.self) { (response) in
      guard let recipes: Recipes = response.value else { return }
      completionHandler(recipes.items)
    }
  }

}



struct Recipe: Decodable, Identifiable {
    let id: Int
    let title: String
    let image: String
    
    enum CodingKeys : String, CodingKey {
        case id
        case title
        case image
    }
}

struct Recipes: Decodable {
    let items: [Recipe]
    
    enum CodingKeys : String, CodingKey {
        case items = "recipes"
    }
    
}

let parse = Parser()
parse.fetchRepositories(completionHandler: {print($0)})

