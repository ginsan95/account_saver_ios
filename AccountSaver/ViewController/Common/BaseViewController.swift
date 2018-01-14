//
//  BaseViewController.swift
//  AccountSaver
//
//  Created by Avery Choke on 6/1/18.
//  Copyright © 2018 P4. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension UIViewController {
    public func showAlertMessage(title: String, message: String, dismissTitle: String = NSLocalizedString("OK", comment: "OK")) {
        self.showAlertMessage(title: title, message: message, actions: [
            UIAlertAction(title: dismissTitle, style: UIAlertActionStyle.cancel, handler: nil)
        ])
    }
    
    public func showAlertMessage(title: String, message: String, actions: [UIAlertAction]) {
        let alertViewController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        for action in actions {
            alertViewController.addAction(action)
        }
        self.present(alertViewController, animated: true, completion: nil)
    }
}
