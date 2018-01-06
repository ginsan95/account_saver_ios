//
//  Account.swift
//  AccountSaver
//
//  Created by Avery Choke on 5/1/18.
//  Copyright © 2018 P4. All rights reserved.
//

import Foundation

public class Account {
    // compulsary
    var gameName: String
    var username: String
    var password: String
    var isLock: Bool
    
    // optional
    var password2: String?
    var email: String?
    var description: String?
    var securityQuestion: [String: String]
    
    init?(json: [String: Any]) {
        return nil;
    }
}
