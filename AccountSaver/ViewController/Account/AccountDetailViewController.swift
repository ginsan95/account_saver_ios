//
//  AccountDetailViewController.swift
//  AccountSaver
//
//  Created by Avery Choke on 9/1/18.
//  Copyright © 2018 P4. All rights reserved.
//

import UIKit
import SDWebImage
import MBProgressHUD

class AccountDetailViewController: UITableViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var logoImageView: RoundedImageView!
    @IBOutlet weak var dateContainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var gameNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var password2TextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var textFields: [UITextField]!
    
    enum ViewType  {
        case add, edit, view
    }
    var viewType: ViewType!
    var account: Account?
    var saveCompleteBlock: ((Account) -> Void)?
    var selectedIconUrl: URL?
    var lockData: (isLocked: Bool, password: String?) = (isLocked: false, password: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textFields = [self.gameNameTextField, self.usernameTextField, self.passwordTextField, self.password2TextField, self.emailTextField, self.phoneTextField]
        let canEdit = self.viewType != .view
        self.logoImageView.sd_setShowActivityIndicatorView(true)
        self.logoImageView.sd_setIndicatorStyle(.gray)
        
        // set enabled or disabled
        for textField in self.textFields {
            textField.isEnabled = canEdit
        }
        self.descriptionTextView.isEditable = canEdit
        
        if canEdit {
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.showIconVC))
            singleTap.numberOfTapsRequired = 1
            self.logoImageView.addGestureRecognizer(singleTap)
        }
        
        // set account view
        self.initAccountView()
        
        // change action button
        switch self.viewType! {
        case .add:
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.addAccount))
            self.addCloseAction()
            self.dateContainerHeight.constant = 0
        case .edit:
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.updateAccount))
            self.addCloseAction()
        case .view:
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.editAccount))
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "editAccountDetailVC" {
            guard let navigationVC: UINavigationController = segue.destination as? UINavigationController, let detailVC: AccountDetailViewController = navigationVC.viewControllers.first as? AccountDetailViewController else {
                return
            }
            detailVC.viewType = .edit
            detailVC.account = self.account
            detailVC.saveCompleteBlock = { (account: Account) in
                self.account = account
                self.initAccountView()
                navigationVC.dismiss(animated: true)
                self.saveCompleteBlock?(account)
            }
            
        } else if segue.identifier == "showIconVC" {
            guard let iconVC: IconViewController = segue.destination as? IconViewController else {
                return
            }
            iconVC.selectedIconBlock = { (url: URL?) in
                self.logoImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "placeholder"))
                self.selectedIconUrl = url
                iconVC.navigationController?.popViewController(animated: true)
            }
            iconVC.selectedIconUrl = self.selectedIconUrl
        }
    }

    func initAccountView() {
        if let account = self.account {
            self.title = account.gameName
            
            // display data
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy hh:mm a"
            
            self.dateLabel.text = dateFormatter.string(from: account.updatedDate)
            self.selectedIconUrl = account.gameIconUrl
            self.logoImageView.sd_setImage(with: account.gameIconUrl, placeholderImage: #imageLiteral(resourceName: "placeholder"))
            self.gameNameTextField.text = account.gameName
            self.usernameTextField.text = account.username
            self.passwordTextField.text = account.password
            self.password2TextField.text = account.password2
            self.emailTextField.text = account.email
            self.phoneTextField.text = account.phoneNumber
            self.descriptionTextView.text = account.description
            
            self.lockData.isLocked = account.isLocked
            self.lockData.password = account.lockPassword
            self.lockButton.isHidden = self.viewType == .view && (self.account == nil || !self.account!.isLocked)
            self.lockButton.setImage(account.isLocked ? #imageLiteral(resourceName: "ic_lock") : #imageLiteral(resourceName: "ic_lock_open"), for: .normal)
        } else {
            self.title = NSLocalizedString("New Account", comment: "New Account")
        }
    }
    
    func addCloseAction() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.dismissVC))
    }
    
    @IBAction func changeLockAccount(_ sender: Any) {
        let canEdit = self.viewType != .view
        guard canEdit else {
            return
        }
        
        let title: String = self.lockData.isLocked ? "Unlock" : "Add Lock"
        let alert: UIAlertController = UIAlertController(title: NSLocalizedString(title, comment: title), message: NSLocalizedString("Enter lock password", comment: "Enter lock password"), preferredStyle: .alert)
        alert.addTextField() { (textField: UITextField) in
            textField.placeholder = NSLocalizedString("Password", comment: "Password")
            textField.isSecureTextEntry = true
        }
        alert.addTextField() { (textField: UITextField) in
            textField.placeholder = NSLocalizedString("Confirm password", comment: "Confirm password")
            textField.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: "Confirm"), style: .default) { (_) in
            let hud: MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = .text
            hud.offset = CGPoint(x: 0, y: MBProgressMaxOffset)
            
            guard let textFields = alert.textFields,
                textFields.count >= 2,
                textFields[0].text == textFields[1].text else {
                    hud.label.text = NSLocalizedString("Failed", comment: "Failed")
                    hud.hide(animated: true, afterDelay: 2)
                    return
            }
            if self.lockData.isLocked { // Unlock
                if self.lockData.password == nil || textFields[0].text == self.lockData.password {
                    self.lockData.isLocked = false
                    self.lockData.password = nil
                    self.lockButton.setImage(#imageLiteral(resourceName: "ic_lock_open"), for: .normal)
                    
                    hud.label.text = NSLocalizedString("Unlocked", comment: "Unlocked")
                    hud.hide(animated: true, afterDelay: 2)
                } else {
                    hud.label.text = NSLocalizedString("Failed", comment: "Failed")
                    hud.hide(animated: true, afterDelay: 2)
                }
            } else { // Lock
                self.lockData.isLocked = true
                self.lockData.password = textFields[0].text
                self.lockButton.setImage(#imageLiteral(resourceName: "ic_lock"), for: .normal)
                
                hud.label.text = NSLocalizedString("Locked", comment: "Locked")
                hud.hide(animated: true, afterDelay: 2)
            }
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @objc func addAccount() {
        guard let account: Account = self.accountFromFields() else {
            return
        }
        
        let hud: MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("Loading", comment: "Loading")
        
        BackendlessAPI.sharedInstance.saveAccount(account) { (account: Account?, errorMessage: String?) in
            hud.hide(animated: true)
            guard let account = account else {
                self.showAlertMessage(title: NSLocalizedString("Error", comment: "Error"), message: errorMessage ?? NSLocalizedString("Failed to add account", comment: "Failed to add account"))
                return
            }
            self.saveCompleteBlock?(account)
        }
    }
    
    @objc func updateAccount() {
        guard let account: Account = self.accountFromFields() else {
            return
        }
        
        let hud: MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("Loading", comment: "Loading")
        
        BackendlessAPI.sharedInstance.updateAccount(account) { (account: Account?, errorMessage: String?) in
            hud.hide(animated: true)
            guard let account = account else {
                self.showAlertMessage(title: NSLocalizedString("Error", comment: "Error"), message: errorMessage ?? NSLocalizedString("Failed to update account", comment: "Failed to update account"))
                return
            }
            self.saveCompleteBlock?(account)
        }
    }
    
    func accountFromFields() -> Account? {
        guard checkDataEntered(),
            let gameName = self.gameNameTextField.text,
            let username = self.usernameTextField.text,
            let password = self.passwordTextField.text
            else {
                return nil
        }
        
        let newAccount:Account!
        if let account = self.account {
            newAccount = account.clone
            newAccount.gameName = gameName
            newAccount.username = username
            newAccount.password = password
        } else {
            newAccount = Account(gameName: gameName, username: username, password: password)
        }
        newAccount.gameIconUrl = self.selectedIconUrl
        newAccount.password2 = self.password2TextField.text
        newAccount.email = self.emailTextField.text
        newAccount.phoneNumber = self.phoneTextField.text
        newAccount.description = self.descriptionTextView.text
        newAccount.isLocked = self.lockData.isLocked
        newAccount.lockPassword = self.lockData.password
        
        return newAccount
    }
    
    func checkDataEntered() -> Bool {
        var allDataEntered = true
        if self.gameNameTextField.text == nil || self.gameNameTextField.text!.isEmpty {
            self.gameNameTextField.placeholder = NSLocalizedString("This field cannot be empty!", comment: "This field cannot be empty!")
            allDataEntered = false
        }
        if self.usernameTextField.text == nil || self.usernameTextField.text!.isEmpty {
            self.usernameTextField.placeholder = NSLocalizedString("This field cannot be empty!", comment: "This field cannot be empty!")
            allDataEntered = false
        }
        if self.passwordTextField.text == nil || self.passwordTextField.text!.isEmpty {
            self.passwordTextField.placeholder = NSLocalizedString("This field cannot be empty!", comment: "This field cannot be empty!")
            allDataEntered = false
        }
        return allDataEntered
    }
    
    @objc func editAccount() {
        self.performSegue(withIdentifier: "editAccountDetailVC", sender: self)
    }
    
    @objc func dismissVC() {
        self.navigationController?.dismiss(animated: true)
    }
    
    @objc func showIconVC() {
        self.performSegue(withIdentifier: "showIconVC", sender: self)
    }
}
