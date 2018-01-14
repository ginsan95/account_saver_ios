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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.textFields = [self.gameNameTextField, self.usernameTextField, self.passwordTextField, self.password2TextField, self.emailTextField, self.phoneTextField]
        let canEdit = self.viewType != .view
        
        // set enabled or disabled
        for textField in self.textFields {
            textField.isEnabled = canEdit
        }
        self.descriptionTextView.isEditable = canEdit
        
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
        }
    }

    func initAccountView() {
        if let account = self.account {
            self.title = account.gameName
            
            // display data
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy hh:mm a"
            
            self.dateLabel.text = dateFormatter.string(from: account.updatedDate)
            self.logoImageView.sd_setImage(with: account.gameIconUrl, placeholderImage: #imageLiteral(resourceName: "placeholder"))
            self.gameNameTextField.text = account.gameName
            self.usernameTextField.text = account.username
            self.passwordTextField.text = account.password
            self.password2TextField.text = account.password2
            self.emailTextField.text = account.email
            self.phoneTextField.text = account.phoneNumber
            self.descriptionTextView.text = account.description
        } else {
            self.title = NSLocalizedString("New Account", comment: "New Account")
        }
    }
    
    func addCloseAction() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.dismissVC))
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
        newAccount.password2 = self.password2TextField.text
        newAccount.email = self.emailTextField.text
        newAccount.phoneNumber = self.phoneTextField.text
        newAccount.description = self.descriptionTextView.text
        
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
}