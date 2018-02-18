//
//  PersonalViewController.swift
//  AccountSaver
//
//  Created by Avery Choke on 17/2/18.
//  Copyright © 2018 P4. All rights reserved.
//

import UIKit
import MBProgressHUD

class PersonalViewController: UITableViewController {

    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let profile: Profile = ProfileManager.sharedInstance.profile {
            self.nameLabel.text = profile.name
        }
    }
    
    @IBAction func logout(_ sender: Any) {
        let hud: MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("Logging out...", comment: "Logging out...")
        
        ProfileManager.sharedInstance.logout {
            hud.hide(animated: true)
            
            guard let loginNVC = UIStoryboard(name: "Login", bundle: nil).instantiateInitialViewController(),
                let navigationVC: UINavigationController = loginNVC as? UINavigationController,
                let loginVC: LoginViewController = navigationVC.viewControllers.first as? LoginViewController else {
                    return
            }
            
            NotificationCenter.default.post(name: .onUserLoggedOut, object: nil)
            
            loginVC.loginSuccessBlock = {
                if let profile: Profile = ProfileManager.sharedInstance.profile {
                    self.nameLabel.text = profile.name
                }
            }
            self.present(loginNVC, animated: true, completion: nil)
        }
    }
    
}
