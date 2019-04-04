//
//  ASSTabBarController.swift
//  AccountSaver
//
//  Created by Avery Choke on 10/2/18.
//  Copyright © 2018 P4. All rights reserved.
//

import UIKit

class ASSTabBarController: UITabBarController {
    var isFirstTime: Bool = true
    var isLoggedIn: Bool {
        return BackendlessAPI.sharedInstance.token != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.isFirstTime {
            if !self.isLoggedIn , let loginVC = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController() {
                self.present(loginVC, animated: true, completion: nil)
            } else {
                NotificationCenter.default.post(name: .onUserLoggedIn, object: nil)
            }
        }
    }
    
}
