//
//  ProfileManager.swift
//  AccountSaver
//
//  Created by Avery Choke on 12/2/18.
//  Copyright © 2018 P4. All rights reserved.
//

import Foundation

class ProfileManager {
    static let TOKEN_KEY: String = "TOKEN_KEY"
    static let sharedInstance: ProfileManager = ProfileManager()
    
    var profile: Profile?
    var token: String?
    
    fileprivate init() {}
    
    func login(username: String, password: String, completion: ((_ profile: Profile?, _ errorMessage: String?) -> Void)?) {
        BackendlessAPI.sharedInstance.login(username: username, password: password) { (profile: Profile?, token: String?, errorMessage: String?) in
            guard let profile = profile,
                let token = token else {
                    completion?(nil, errorMessage)
                    return
            }
            
            self.profile = profile
            self.token = token
            UserDefaults.standard.set(token, forKey: ProfileManager.TOKEN_KEY)
            
            completion?(profile, errorMessage)
        }
    }
}
