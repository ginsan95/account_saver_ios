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
        
        self.initView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "editAccountDetailVC" {
            guard let navigationVC: UINavigationController = segue.destination as? UINavigationController, let detailVC: AccountDetailViewController = navigationVC.viewControllers.first as? AccountDetailViewController else {
                return
            }
            detailVC.viewType = .edit
            detailVC.account = self.account
        }
    }

    func initView() {
        self.textFields = [self.gameNameTextField, self.usernameTextField, self.passwordTextField, self.password2TextField, self.emailTextField, self.phoneTextField]
        let canEdit = self.viewType != .view
        
        // set enabled or disabled
        for textField in self.textFields {
            textField.isEnabled = canEdit
        }
        self.descriptionTextView.isEditable = canEdit
        
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
    
    func addCloseAction() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.dismissVC))
    }
    
    @objc func addAccount() {
        guard checkDataEntered(),
            let gameName = self.gameNameTextField.text,
            let username = self.usernameTextField.text,
            let password = self.passwordTextField.text
            else {
                return
        }
        
        let account = Account(gameName: gameName, username: username, password: password)
        account.password2 = self.password2TextField.text
        account.email = self.emailTextField.text
        account.phoneNumber = self.phoneTextField.text
        account.description = self.descriptionTextView.text
        
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

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
