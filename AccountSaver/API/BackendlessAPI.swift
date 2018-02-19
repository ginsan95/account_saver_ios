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
    fileprivate static let pageSize: Int = 10
    fileprivate static let allowedCharacterSet = CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted
    
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
    
    // Profile
    func login(username: String, password: String, completion: ((_ profile: Profile?, _ errorMessage: String?) -> Void)?) {
        let params: [String: String] = ["login": username, "password": password]
        
        self.request(method: .post, path: "/users/login", parameters: params).responseJSON { (response: DataResponse<Any>) in
            guard let objectJson: [String: Any] = response.result.value as? [String: Any],
                let token: String = objectJson["user-token"] as? String,
                let profile: Profile = Profile(json: objectJson) else {
                completion?(nil, response.errorMessage ?? response.result.error?.localizedDescription)
                return
            }
            self.token = token
            completion?(profile, nil)
        }
    }
    
    func logout(completion: (() -> Void)?) {
        self.request(method: .get, path: "/users/logout").responseJSON { (response: DataResponse<Any>) in
            self.token = nil
            completion?()
        }
    }
    
    func signUp(username: String, name: String, password: String, completion: ((_ success: Bool, _ errorMessage: String?) -> Void)?) {
        let params: [String: String] = ["username": username, "name": name, "password": password]
        
        self.request(method: .post, path: "/users/register", parameters: params).responseJSON { (response: DataResponse<Any>) in
            guard let objectJson: [String: Any] = response.result.value as? [String: Any],
                let _: String = objectJson["objectId"] as? String else {
                    completion?(false, response.errorMessage ?? response.result.error?.localizedDescription)
                    return
            }
            completion?(true, nil)
        }
    }
    //
    
    func fetchAccounts(offset: Int, completion: ((_ accounts: [Account], _ errorMessage: String?) -> Void)?) {
        self.fetchAccounts(offset: offset, searchTerm: nil, completion: completion)
    }
    
    func fetchAccounts(offset: Int, searchTerm: String?, completion: ((_ accounts: [Account], _ errorMessage: String?) -> Void)?) {
        var accounts: [Account] = []
        
        var encoded: String = ""
        if let profile: Profile = ProfileManager.sharedInstance.profile {
            encoded += "ownerId='\(profile.ownerId)'"
        }
        if let searchTerm = searchTerm {
            if !encoded.isEmpty {
                encoded += " AND "
            }
            encoded += "game_name LIKE '%\(searchTerm)%'"
        }
        encoded = encoded.addingPercentEncoding(withAllowedCharacters: BackendlessAPI.allowedCharacterSet) ?? ""
        
        self.request(method: .get, path: "/data/Account?where=\(encoded)&sortBy=game_name&pageSize=\(BackendlessAPI.pageSize)&offset=\(offset)").responseJSON { (response: DataResponse<Any>) in
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
    
    func saveAccount(_ account: Account, completion: ((_ account: Account?, _ errorMessage: String?) -> Void)?) {
        self.request(method: .post, path: "/data/Account", parameters: account.json).responseJSON { (response: DataResponse<Any>) in
            guard let objectJson: [String: Any] = response.result.value as? [String: Any],
                let newAccount: Account = Account(json: objectJson) else {
                    completion?(nil, response.errorMessage ?? response.result.error?.localizedDescription)
                    return
            }
            completion?(newAccount, nil)
        }
    }
    
    func updateAccount(_ account: Account, completion: ((_ account: Account?, _ errorMessage: String?) -> Void)?) {
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
    
    func deleteAccount(_ account: Account, completion: ((_ success: Bool, _ errorMessage: String?) -> Void)?) {
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
    
    func fetchGameIcons(completion: ((_ urls: [URL]) -> Void)?) {
        guard let profile: Profile = ProfileManager.sharedInstance.profile else {
            completion?([])
            return
        }
        
        self.request(method: .get, path: "/files/game_icon/\(profile.ownerId)?pageSize=100").responseJSON { (response: DataResponse<Any>) in
            guard let objectJson: [[String: Any]] = response.result.value as? [[String: Any]] else {
                completion?([])
                return
            }
            var urls: [URL] = []
            for json in objectJson {
                if let urlString: String = json["publicUrl"] as? String, let url: URL = URL(string: urlString) {
                    urls.append(url)
                }
            }
            completion?(urls)
        }
    }
    
    func uploadGameIcon(_ image: UIImage, completion: ((_ url: URL?, _ errorMessage: String?) -> Void)?) {
        guard let profile: Profile = ProfileManager.sharedInstance.profile else {
            completion?(nil, nil)
            return
        }
        
        let name: String = "game-icon-\(Date().timeIntervalSince1970).jpeg"
        var urlComponents = URLComponents(string: BackendlessAPI.baseUrlString)
        urlComponents?.path += "/files/game_icon/\(profile.ownerId)/\(name)"
        
        guard let imageData: Data = UIImageJPEGRepresentation(image, 1.0),
            let url = urlComponents?.url else {
                completion?(nil, nil)
                return
        }
        
        let headers: [String: String] = ["Content-Type": "multipart/form-data"]
        
        Alamofire.upload(multipartFormData: { (multipartFormData: MultipartFormData) in
            multipartFormData.append(imageData, withName: "photo", fileName: name, mimeType: "image/jpeg")
        }, usingThreshold: UInt64(), to: url, method: .post, headers: headers) { (encodingResult: SessionManager.MultipartFormDataEncodingResult) in
            switch encodingResult {
            case.success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                upload.responseJSON { (response: DataResponse<Any>) in
                    guard let objectJson: [String: Any] = response.result.value as? [String: Any],
                        let urlStr: String = objectJson["fileURL"] as? String,
                        let url: URL = URL(string: urlStr) else {
                            completion?(nil, response.errorMessage ?? response.result.error?.localizedDescription)
                            return
                    }
                    completion?(url, nil)
                }
                
            case .failure(let encodingError):
                completion?(nil, encodingError.localizedDescription)
            }
        }
    }
    
    func deleteGameIcon(url: URL) {
        Alamofire.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: nil)
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
