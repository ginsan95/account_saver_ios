//
//  BaseViewController.swift
//  AccountSaver
//
//  Created by Avery Choke on 6/1/18.
//  Copyright © 2018 P4. All rights reserved.
//

import UIKit
import Photos

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

// Alert messages
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

// Permissions
extension UIViewController {
    public func requestForPhotoPermission(reason: String, authorized: (() -> Void)?) {
        let authorizationStatus: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        let alertTitle: String = NSLocalizedString("Photo Library Permission", comment: "Photo Library Permission")
        
        switch authorizationStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (selectedStatus: PHAuthorizationStatus) in
                switch selectedStatus {
                case .authorized:
                    authorized?()
                default:
                    // Ignore
                    break
                }
            })
        case .authorized:
            authorized?()
        case .restricted, .denied:
            self.showAlertMessage(title: alertTitle, message: reason, actions: [
                UIAlertAction(title: NSLocalizedString("Later", comment: "Later"), style: UIAlertActionStyle.cancel),
                UIAlertAction(title: NSLocalizedString("Settings", comment: "Settings"), style: UIAlertActionStyle.default) { (action: UIAlertAction) in
                    guard let settingsUrl: URL = URL(string: UIApplicationOpenSettingsURLString),
                       UIApplication.shared.canOpenURL(settingsUrl) else {
                            return;
                    }
                    UIApplication.shared.open(settingsUrl, options: [:])
                }
            ])
        }
    }
}
