//
//  Account.swift
//  AccountSaver
//
//  Created by Avery Choke on 5/1/18.
//  Copyright © 2018 P4. All rights reserved.
//

import Foundation

class Account {
    // compulsary
    var gameName: String
    var username: String
    var password: String
    var isLocked: Bool
    var updatedDate: Date
    
    // optional
    var gameIconUrl: URL?
    var password2: String?
    var email: String?
    var phoneNumber: String?
    var description: String?
    var securityQuestion: [String: String]
    
    var encrytedUsername: String {
        guard self.username.count > 1 else {
            return self.username
        }
        
        let subIndex = self.username.count > 4 ? 4 : self.username.count - 1
        var subString = self.username.prefix(4)
        for _ in 0..<(self.username.count - subIndex) {
            subString.append(contentsOf: "*")
        }
        return String(subString)
    }
    
    init?(json: [String: Any]) {
        guard let gameName: String = json["game_name"] as? String,
            let username: String = json["username"] as? String,
            let password: String = json["password"] as? String,
            let isLocked: Bool = json["is_locked"] as? Bool,
            let createdInterval: Double = json["created"] as? Double else {
                return nil
        }
        
        self.gameName = gameName
        self.username = username
        self.password = password
        self.isLocked = isLocked
        self.updatedDate = Date(timeIntervalSince1970: (json["updated"] as? Double ?? createdInterval) / 1000)
        
        if let gameIconString = json["game_icon"] as? String, let gameIconUrl = URL(string: gameIconString) {
            self.gameIconUrl = gameIconUrl
        }
        if let password2 = json["password2"] as? String {
            self.password2 = password2
        }
        if let email = json["email"] as? String {
            self.email = email
        }
        if let phoneNumber = json["phoneNumber"] as? String {
            self.phoneNumber = phoneNumber
        }
        if let description = json["description"] as? String {
            self.description = description
        }
        self.securityQuestion = [:]
    }
}
