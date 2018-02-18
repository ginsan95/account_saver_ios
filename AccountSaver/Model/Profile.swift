//
//  Profile.swift
//  AccountSaver
//
//  Created by Avery Choke on 12/2/18.
//  Copyright © 2018 P4. All rights reserved.
//

import Foundation

class Profile {
    let name: String
    let ownerId: String
    
    init?(json: [String: Any]) {
        guard let name: String = json["name"] as? String,
            let ownerId: String = json["ownerId"] as? String else {
                return nil
        }
        
        self.name = name
        self.ownerId = ownerId
    }
}
