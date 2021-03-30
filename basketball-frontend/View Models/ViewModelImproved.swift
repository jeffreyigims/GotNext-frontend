////
////  ViewModelImproved.swift
////  basketball-frontend
////
////  Created by Jeffrey Igims on 3/24/21.
////  Copyright © 2021 Matthew Cruz. All rights reserved.
////
//
//import Foundation
//import Alamofire
//import SwiftUI
//import Photos
//import Contacts
//import MessageUI
//
//let url = "http://secure-hollows-77457.herokuapp.com"
//
//struct Request<T> {
//  let method: HTTPMethod
//  let params: [String: Any]
//  let exten: String
//  let decode: T
//  let success: ((AFDataResponse<T>) -> ())
//  let failure: ((AFDataResponse<T>) -> ())
//}
//
//class ViewModelImproved: ObservableObject {
//
//  var headers: HTTPHeaders?
//  @Published var userID: Int?
//
//  func request<T>(req: Request<T>) where T : Decodable {
//    AF.request(url + req.exten, method: req.method, parameters: req.params, headers: self.headers!)
//      .validate()
//      .responseDecodable {
//        ( response: AFDataResponse<T>) in
//        switch response.result {
//        case .success:
//          req.success(response)
//        case .failure:
//          req.failure(response)
//        }
//      }
//  }
//
//  func getGames() {
//    let params: Parameters = [
//      "user_id": self.userID!
//    ]
//    var success: (AFDataResponse<ListData<Games>>) -> () = { (value) in
//      self.games = value.data
//      self.gameAnnotations = value.data.map({ GameAnnotation(id: $0.id, subtitle: $0.name, title: $0.name, latitude: $0.latitude, longitude: $0.longitude)})
//    }
//    var failure: (AFDataResponse<ListData<Games>>) -> () = { (value) in
//
//    }
//    let req: Request = (method: .get, params: params, exten: "/get_games", decode: ListData<Games>, success: success, failure: failure)
//  }
//
//
//}
//
