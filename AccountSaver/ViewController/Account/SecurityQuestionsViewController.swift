//
//  SecurityQuestionsViewController.swift
//  AccountSaver
//
//  Created by Avery Choke on 30/1/18.
//  Copyright © 2018 P4. All rights reserved.
//

import UIKit
import MBProgressHUD

class SecurityQuestionsViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var securityQuestions: [String: String] = [:] {
        didSet {
            self.initQuestions()
        }
    }
    // For tableview cell
    var questions: [(String, String)] = []
    var doneBlock: ((_ securityQuestions: [String: String]) -> Void)?
    var canEdit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !self.canEdit {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController || self.isBeingDismissed {
            self.doneBlock?(self.securityQuestions)
        }
    }
    
    @IBAction func addQuestion(_ sender: Any) {
        let alert: UIAlertController = UIAlertController(title: nil, message: NSLocalizedString("Add security question", comment: "Add security question"), preferredStyle: .alert)
        alert.addTextField() { (textField: UITextField) in
            textField.placeholder = NSLocalizedString("Question", comment: "Question")
        }
        alert.addTextField() { (textField: UITextField) in
            textField.placeholder = NSLocalizedString("Answer", comment: "Answer")
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: "Confirm"), style: .default) { (_) in
            let hud: MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.mode = .text
            hud.offset = CGPoint(x: 0, y: MBProgressMaxOffset)
            
            guard let textFields = alert.textFields,
                textFields.count >= 2,
                let question: String = textFields[0].text,
                let answer: String = textFields[1].text else {
                    hud.label.text = NSLocalizedString("Failed", comment: "Failed")
                    hud.hide(animated: true, afterDelay: 2)
                    return
            }
            
            self.securityQuestions[question] = answer
            self.tableView.reloadData()
            
            hud.label.text = NSLocalizedString("Added successfully", comment: "Added successfully")
            hud.hide(animated: true, afterDelay: 2)
        })
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func initQuestions() {
        self.questions.removeAll()
        for question in self.securityQuestions {
            self.questions.append(question)
        }
    }
}

extension SecurityQuestionsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "SecurityQuestionCell", for: indexPath)
        cell.textLabel?.text = self.questions[indexPath.row].0
        cell.detailTextLabel?.text = self.questions[indexPath.row].1
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let question: String = self.questions[indexPath.row].0
            self.securityQuestions[question] = nil
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return self.canEdit ? .delete : .none
    }
}
