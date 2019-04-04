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
    var id: String?
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
    var lockPassword: String?
    var securityQuestions: [String: String]
    
    var encrytedUsername: String {
        guard self.username.count > 1 else {
            return self.username
        }
        
        let subIndex = self.username.count > 4 ? 4 : self.username.count - 1
        var subString = self.username.prefix(subIndex)
        for _ in 0..<(self.username.count - subIndex) {
            subString.append(contentsOf: "*")
        }
        return String(subString)
    }
    
    var json: [String: Any] {
        var body: [String: Any] = [
            "game_name": self.gameName,
            "username": self.username,
            "password": self.password,
            "is_locked": self.isLocked
        ]
        if let gameIconUrl = self.gameIconUrl {
            body["game_icon"] = gameIconUrl.absoluteString
        }
        if let password2 = self.password2, !password2.isEmpty {
            body["password2"] = password2
        }
        if let email = self.email, !email.isEmpty {
            body["email"] = email
        }
        if let phoneNumber = self.phoneNumber, !phoneNumber.isEmpty {
            body["phone_number"] = phoneNumber
        }
        if let description = self.description, !description.isEmpty {
            body["description"] = description
        }
        body["lock_password"] = self.lockPassword
        if let securityQuestionsString = self.securityQuestionsString {
            body["security_questions"] = securityQuestionsString
        }
        return body
    }
    
    var clone: Account {
        let account: Account = Account(gameName: self.gameName, username: self.username, password: self.password)
        account.id = self.id
        account.isLocked = self.isLocked
        account.updatedDate = self.updatedDate
        account.gameIconUrl = self.gameIconUrl
        account.password2 = self.password2
        account.email = self.email
        account.phoneNumber = self.phoneNumber
        account.description = self.description
        account.lockPassword = self.lockPassword
        account.securityQuestions = self.securityQuestions
        return account
    }
    
    var securityQuestionsString: String? {
        guard !self.securityQuestions.isEmpty,
            let securityData: Data = try? JSONSerialization.data(withJSONObject: self.securityQuestions),
            let securityString: String = String(data: securityData, encoding: .utf8) else {
            return nil
        }
        return securityString
    }
    
    // For creating new account
    init(gameName: String, username: String, password: String) {
        self.gameName = gameName
        self.username = username
        self.password = password
        self.isLocked = false
        self.updatedDate = Date()
        self.securityQuestions = [:]
    }
    
    init?(json: [String: Any]) {
        guard let id: String = json["objectId"] as? String,
            let gameName: String = json["game_name"] as? String,
            let username: String = json["username"] as? String,
            let password: String = json["password"] as? String,
            let isLocked: Bool = json["is_locked"] as? Bool,
            let createdInterval: Double = json["created"] as? Double else {
                return nil
        }
        
        self.id = id
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
        if let phoneNumber = json["phone_number"] as? String {
            self.phoneNumber = phoneNumber
        }
        if let description = json["description"] as? String {
            self.description = description
        }
        if let lockPassword = json["lock_password"] as? String {
            self.lockPassword = lockPassword
        }
        if let securityString = json["security_questions"] as? String, let dictionary = securityString.toJsonDictionary(), let securityQuestions: [String: String] = dictionary as? [String: String] {
            self.securityQuestions = securityQuestions
        } else {
            self.securityQuestions = [:]
        }
    }
}

extension Account: Equatable {
    static func ==(lhs: Account, rhs: Account) -> Bool {
        if let id1 = lhs.id, let id2 = rhs.id {
            return id1 == id2
        } else {
            return false
        }
    }
}

extension String {
    func toJsonDictionary() -> [String: Any]? {
        guard let data: Data = self.data(using: .utf8),
            let json: Any = try? JSONSerialization.jsonObject(with: data),
            let dictionary: [String: Any] = json as? [String: Any] else {
                return nil
        }
        return dictionary
    }
}

extension CDAccount {
    var json: [String: Any]? {
        guard let gameName = self.gameName,
            let username = self.username,
            let password = self.password else {
                return nil
        }
        
        var body: [String: Any] = [
            "game_name": gameName,
            "username": username,
            "password": password,
            "is_locked": isLocked
        ]
        if let gameIconUrl = self.gameIconUrl {
            body["game_icon"] = gameIconUrl.absoluteString
        }
        if let password2 = self.password2, !password2.isEmpty {
            body["password2"] = password2
        }
        if let email = self.email, !email.isEmpty {
            body["email"] = email
        }
        if let phoneNumber = self.phoneNumber, !phoneNumber.isEmpty {
            body["phone_number"] = phoneNumber
        }
        if let description = self.cDescription, !description.isEmpty {
            body["description"] = description
        }
        body["lock_password"] = self.lockPassword
        if let securityQuestionsJson = self.securityQuestionsJson {
            body["security_questions"] = securityQuestionsJson
        }
        return body
    }
    
    var securityQuestions: [String: String] {
        if let securityQuestionsJson = self.securityQuestionsJson, let dictionary = securityQuestionsJson.toJsonDictionary(), let securityQuestions: [String: String] = dictionary as? [String: String] {
            return securityQuestions
        } else {
            return [:]
        }
    }
    
    var encrytedUsername: String {
        guard let username = self.username else {
            return ""
        }
        guard username.count > 1 else {
            return username
        }
        
        let subIndex = username.count > 4 ? 4 : username.count - 1
        var subString = username.prefix(subIndex)
        for _ in 0..<(username.count - subIndex) {
            subString.append(contentsOf: "*")
        }
        return String(subString)
    }
    
    func initData(with json: [String: Any]) throws {
        guard let id: String = json["objectId"] as? String,
            let gameName: String = json["game_name"] as? String,
            let username: String = json["username"] as? String,
            let password: String = json["password"] as? String,
            let isLocked: Bool = json["is_locked"] as? Bool,
            let createdInterval: Double = json["created"] as? Double else {
                throw ApiError.dataError
        }
        
        self.id = id
        self.gameName = gameName
        self.username = username
        self.password = password
        self.isLocked = isLocked
        self.updatedDate = Date(timeIntervalSince1970: (json["updated"] as? Double ?? createdInterval) / 1000)
    }
    
    func initData(with model: Account) throws {
        guard let id: String = model.id else {
            throw ApiError.dataError
        }
        
        self.id = id
        self.gameName = model.gameName
        self.username = model.username
        self.password = model.password
        self.isLocked = model.isLocked
        self.updatedDate = model.updatedDate
        
        self.gameIconUrl = model.gameIconUrl
        self.password2 = model.password2
        self.email = model.email
        self.phoneNumber = model.phoneNumber
        self.cDescription = model.description
        self.lockPassword = model.lockPassword
        self.securityQuestionsJson = model.securityQuestionsString
    }
}
