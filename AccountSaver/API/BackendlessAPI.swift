//
//  BackendlessAPI.swift
//  AccountSaver
//
//  Created by Avery Choke on 6/1/18.
//  Copyright © 2018 P4. All rights reserved.
//

import Foundation
import Alamofire

class BackendlessAPI {
    fileprivate static let singleton: BackendlessAPI = BackendlessAPI()
    fileprivate static let baseUrlString: String = "https://api.backendless.com/FDB083B0-BAF9-5AA7-FF6B-507294178300/AD715598-37F8-FC4D-FFC8-56D94399D600"
    
    fileprivate let baseHeaders: [String: String] = ["Content-Type": "application/json"]
    var token: String?
    
    static var sharedInstance: BackendlessAPI {
        return BackendlessAPI.singleton
    }
    
    fileprivate func request(method: HTTPMethod, path: String, parameters: [String: Any]? = nil, encoding: ParameterEncoding = JSONEncoding.default) -> DataRequest {
        var headers: [String: String] = [:]
        
        for (key, value) in self.baseHeaders {
            headers[key] = value
        }
        
        if let token = self.token {
            headers["user-token"] = token
        }
        
        let urlComponents: URLComponents? = URLComponents(string: BackendlessAPI.baseUrlString + path)
        let url: URL = (urlComponents?.url)!
        
        return Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
    }
    
    func fetchAccounts(completion: (([Account], Error?) -> Void)?) {
        var accounts: [Account] = []
        
        self.request(method: .get, path: "/data/Account").responseJSON { (response: DataResponse<Any>) in
            guard let objectJson: [[String: Any]] = response.result.value as? [[String: Any]] else {
                completion?(accounts, response.error)
                return
            }
            
            for json in objectJson {
                if let account = Account(json: json) {
                    accounts.append(account)
                }
            }
            
            completion?(accounts, nil)
        }
    }
}
