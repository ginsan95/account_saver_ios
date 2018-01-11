//
//  AccountDetailViewController.swift
//  AccountSaver
//
//  Created by Avery Choke on 9/1/18.
//  Copyright © 2018 P4. All rights reserved.
//

import UIKit
import SDWebImage

class AccountDetailViewController: UITableViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var logoImageView: RoundedImageView!
    
    @IBOutlet weak var gameNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var password2TextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var textFields: [UITextField]!
    
    var isEditMode: Bool = true
    var account: Account!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        guard let _ = self.account else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        self.initView()
    }

    fileprivate func initView() {
        self.title = self.account.gameName
        
        self.textFields = [self.gameNameTextField, self.usernameTextField, self.passwordTextField, self.password2TextField, self.emailTextField, self.phoneTextField]
        
        // set enabled or disabled
        for textField in self.textFields {
            textField.isEnabled = self.isEditMode
        }
        self.descriptionTextView.isEditable = self.isEditMode
        
        // display data
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm a"
        
        self.dateLabel.text = dateFormatter.string(from: self.account.updatedDate)
        self.logoImageView.sd_setImage(with: self.account.gameIconUrl, placeholderImage: #imageLiteral(resourceName: "placeholder"))
        self.gameNameTextField.text = self.account.gameName
        self.usernameTextField.text = self.account.username
        self.passwordTextField.text = self.account.password
        self.password2TextField.text = self.account.password2
        self.emailTextField.text = self.account.email
        self.phoneTextField.text = self.account.phoneNumber
        self.descriptionTextView.text = self.account.description
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
