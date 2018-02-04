//
//  SecurityQuestionsViewController.swift
//  AccountSaver
//
//  Created by Avery Choke on 30/1/18.
//  Copyright © 2018 P4. All rights reserved.
//

import UIKit

class SecurityQuestionsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var securityQuestions: [String: String] = [:] {
        didSet {
            self.questions.removeAll()
            for question in self.securityQuestions {
                self.questions.append(question)
            }
        }
    }
    // For tableview cell
    var questions: [(String, String)] = []
    var doneBlock: ((_ securityQuestions: [String: String]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController || self.isBeingDismissed {
            self.doneBlock?(self.securityQuestions)
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
}
