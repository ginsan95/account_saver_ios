//
//  ProfileManager.swift
//  AccountSaver
//
//  Created by Avery Choke on 12/2/18.
//  Copyright © 2018 P4. All rights reserved.
//

import Foundation

class ProfileManager {
    static let sharedInstance: ProfileManager = ProfileManager()
    
    var profile: Profile?
    
    fileprivate init() {}
    
    func login(username: String, password: String, completion: ((_ profile: Profile?, _ errorMessage: String?) -> Void)?) {
        BackendlessAPI.sharedInstance.login(username: username, password: password) { (profile: Profile?, errorMessage: String?) in
            guard let profile = profile else {
                completion?(nil, errorMessage)
                return
            }
            self.profile = profile            
            completion?(profile, errorMessage)
        }
    }
    
    func logout(completion: (() -> Void)?) {
        BackendlessAPI.sharedInstance.logout {
            self.profile = nil
            completion?()
        }
    }
}
