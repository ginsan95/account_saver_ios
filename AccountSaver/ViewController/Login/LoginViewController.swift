//
//  LoginViewController.swift
//  AccountSaver
//
//  Created by Avery Choke on 11/2/18.
//  Copyright © 2018 P4. All rights reserved.
//

import UIKit
import MBProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var loginSuccessBlock: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    @IBAction func login(_ sender: Any) {
        guard let username: String = self.usernameTextField.text,
            !username.isEmpty,
            let password: String = self.passwordTextField.text,
            !password.isEmpty else {
                self.showAlertMessage(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Please enter all the fields", comment: "Please enter all the fields"))
                return
        }
        
        let hud: MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("Logging in...", comment: "Logging in...")
        
        ProfileManager.sharedInstance.login(username: username, password: password) { (profile: Profile?, errorMessage: String?) in
            hud.hide(animated: true)
            guard let _ = profile else {
                self.showAlertMessage(title: NSLocalizedString("Error", comment: "Error"), message: errorMessage ?? NSLocalizedString("Failed to login", comment: "Failed to login"))
                return
            }
            
            NotificationCenter.default.post(name: .onUserLoggedIn, object: nil)
            self.loginSuccessBlock?()
            self.dismiss(animated: true)
        }
    }
    
}
