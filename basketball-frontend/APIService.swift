//
//  APIService.swift
//  basketball-frontend
//
//  Created by Jeffrey Igims on 3/1/22.
//  Copyright © 2022 Matthew Cruz. All rights reserved.
//

import Foundation
import Alamofire

struct Req<T> {
    let method: HTTPMethod
    let params: Parameters
    let exten: String
    let completion: ((AFDataResponse<T>) -> ())
}

class APIService {
    
    private static func req<T>(req: Req<T>, headers: HTTPHeaders?) where T : Decodable {
        AF.request(ADDRESS + req.exten, method: req.method, parameters: req.params, headers: headers)
            .validate()
            .responseDecodable {
                ( response: AFDataResponse<T>) in
                req.completion(response)
            }
    }
    
    static func createDevice(user_id: Int, token: Data, completion: @escaping ((AFDataResponse<Int>) -> ()), headers: HTTPHeaders?) -> () {
        let params: [String: Any] = [
            "user_id": user_id,
            "token": token
        ]
        let req: Req = Req(method: .post, params: params, exten: DEVICES, completion: completion)
        self.req(req: req, headers: headers)
    }
}
