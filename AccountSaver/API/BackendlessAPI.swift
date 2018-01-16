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
    
    func fetchAccounts(completion: (([Account], String?) -> Void)?) {
        var accounts: [Account] = []
        
        self.request(method: .get, path: "/data/Account?sortBy=game_name").responseJSON { (response: DataResponse<Any>) in
            guard let objectJson: [[String: Any]] = response.result.value as? [[String: Any]] else {
                completion?(accounts, response.errorMessage ?? response.result.error?.localizedDescription)
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
    
    func saveAccount(_ account: Account, completion: ((Account?, String?) -> Void)?) {
        self.request(method: .post, path: "/data/Account", parameters: account.json).responseJSON { (response: DataResponse<Any>) in
            guard let objectJson: [String: Any] = response.result.value as? [String: Any],
                let newAccount: Account = Account(json: objectJson) else {
                    completion?(nil, response.errorMessage ?? response.result.error?.localizedDescription)
                    return
            }
            completion?(newAccount, nil)
        }
    }
    
    func updateAccount(_ account: Account, completion: ((Account?, String?) -> Void)?) {
        guard let id = account.id else {
            completion?(account, nil)
            return
        }
        
        self.request(method: .put, path: "/data/Account/\(id)", parameters: account.json).responseJSON { (response: DataResponse<Any>) in
            guard let objectJson: [String: Any] = response.result.value as? [String: Any],
                let _: String = objectJson["objectId"] as? String else {
                    completion?(nil, response.errorMessage ?? response.result.error?.localizedDescription)
                    return
            }
            completion?(account, nil)
        }
    }
    
    func deleteAccount(_ account: Account, completion: ((Bool, String?) -> Void)?) {
        guard let id = account.id else {
            completion?(false, nil)
            return
        }
        
        self.request(method: .delete, path: "/data/Account/\(id)").responseJSON { (response: DataResponse<Any>) in
            guard let objectJson: [String: Any] = response.result.value as? [String: Any],
                let _ = objectJson["deletionTime"] else {
                    completion?(false, response.errorMessage ?? response.result.error?.localizedDescription)
                    return;
            }
            completion?(true, nil)
        }
    }
}

extension DataResponse {
    var errorMessage: String? {
        guard let objectJson: [String: Any] = self.result.value as? [String: Any],
            let message: String = objectJson["message"] as? String else {
                return nil
        }
        return message
    }
}
