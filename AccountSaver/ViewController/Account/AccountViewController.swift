//
//  AccountViewController.swift
//  AccountSaver
//
//  Created by Avery Choke on 5/1/18.
//  Copyright © 2018 P4. All rights reserved.
//

import UIKit
import SDWebImage

class AccountViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!

    var accounts: [Account] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(fetchAccounts), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.refreshControl.beginRefreshing()
        self.fetchAccounts()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showAccountDetailVC" {
            guard let detailVC: AccountDetailViewController = segue.destination as? AccountDetailViewController, let indexPath: IndexPath = self.tableView.indexPathForSelectedRow else {
                return
            }
            detailVC.viewType = .view
            detailVC.account = self.accounts[indexPath.row]
            detailVC.saveCompleteBlock = { (account: Account) in
                let oldIndex = self.accounts.index(of: account)!
                self.accounts.remove(at: oldIndex)
                self.accounts.append(account)
                self.accounts.sort {
                    return $0.gameName < $1.gameName
                }
                
                let index = self.accounts.index(of: account)
                if let index = index, index == oldIndex {
                    self.tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
                } else {
                    self.tableView.reloadData()
                }
            }
            
        } else if segue.identifier == "addAccountDetailVC" {
            guard let navigationVC: UINavigationController = segue.destination as? UINavigationController, let detailVC: AccountDetailViewController = navigationVC.viewControllers.first as? AccountDetailViewController else {
                return
            }
            detailVC.viewType = .add
            detailVC.saveCompleteBlock = { (account: Account) in
                self.accounts.append(account)
                self.accounts.sort {
                    return $0.gameName < $1.gameName
                }
                
                let index = self.accounts.index(of: account)
                if let index = index {
                    self.tableView.insertRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
                } else {
                    self.tableView.reloadData()
                }
                
                navigationVC.dismiss(animated: true)
            }
        }
    }
    
    @objc func fetchAccounts() {
        BackendlessAPI.sharedInstance.fetchAccounts { (accounts: [Account], errorMessage: String?) in
            guard errorMessage == nil else {
                self.refreshControl.endRefreshing()
                return
            }
            
            self.accounts = accounts
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
}

extension AccountViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accounts.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AccountCell = tableView.dequeueReusableCell(withIdentifier: "AccountCell", for: indexPath) as! AccountCell
        let account = self.accounts[indexPath.row]
        
        cell.logoImageView.sd_setImage(with: account.gameIconUrl, placeholderImage: #imageLiteral(resourceName: "placeholder"))
        cell.mainTextLabel.text = account.gameName
        cell.subLabel.text = account.encrytedUsername
        cell.rightImageView.isHidden = !account.isLocked
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
