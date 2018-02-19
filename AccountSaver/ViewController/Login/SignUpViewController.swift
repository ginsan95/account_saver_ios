//
//  SignUpViewController.swift
//  AccountSaver
//
//  Created by Avery Choke on 18/2/18.
//  Copyright © 2018 P4. All rights reserved.
//

import UIKit
import MBProgressHUD

class SignUpViewController: UIViewController {

    @IBOutlet weak var usernameTextField: RoundedTextField!
    @IBOutlet weak var nameTextField: RoundedTextField!
    @IBOutlet weak var passwordTextField: RoundedTextField!
    @IBOutlet weak var confirmPasswordTextField: RoundedTextField!
    
    var signUpSuccessBlock: ((_ username: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func signUp(_ sender: Any) {
        guard let username: String = self.usernameTextField.text,
            !username.isEmpty,
            let name: String = self.nameTextField.text,
            !name.isEmpty,
            let password: String = self.passwordTextField.text,
            !password.isEmpty,
            let confirmPassword: String = self.confirmPasswordTextField.text,
            !confirmPassword.isEmpty else {
                self.showAlertMessage(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("Please enter all the fields", comment: "Please enter all the fields"))
                return
        }
        
        guard password == confirmPassword else {
            self.showAlertMessage(title: NSLocalizedString("Error", comment: "Error"), message: NSLocalizedString("The confirm password is not the same as the password", comment: "The confirm password is not the same as the password"))
            return
        }
        
        let hud: MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("Signing up...", comment: "Signing up...")
        
        BackendlessAPI.sharedInstance.signUp(username: username, name: name, password: password) { (success: Bool, errorMessage: String?) in
            hud.hide(animated: true)
            guard success else {
                self.showAlertMessage(title: NSLocalizedString("Error", comment: "Error"), message: errorMessage ?? NSLocalizedString("Failed to sign up", comment: "Failed to sign up"))
                return
            }
            self.signUpSuccessBlock?(username)
        }
    }
    
}
