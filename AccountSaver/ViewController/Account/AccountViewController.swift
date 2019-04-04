//
//  AccountViewController.swift
//  AccountSaver
//
//  Created by Avery Choke on 5/1/18.
//  Copyright © 2018 P4. All rights reserved.
//

import UIKit
import SDWebImage
import MBProgressHUD

class AccountViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    var searchController: UISearchController!

    var accounts: [CDAccount] = []
    var isFetching: Bool = false
    var searchTerm: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        // Search
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.hidesNavigationBarDuringPresentation = true
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.sizeToFit()
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.definesPresentationContext = true
        
        // Refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(self.refreshAccounts), for: UIControl.Event.valueChanged)
        self.tableView.addSubview(refreshControl)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.fetchStartingData), name: .onUserLoggedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.clearAccounts), name: .onUserLoggedOut, object: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showAccountDetailVC" {
            guard let detailVC: AccountDetailViewController = segue.destination as? AccountDetailViewController, let indexPath: IndexPath = self.tableView.indexPathForSelectedRow else {
                return
            }
            detailVC.viewType = .view
            detailVC.account = self.accounts[indexPath.row]
            detailVC.saveCompleteBlock = { (account: CDAccount) in
                let oldIndex = self.accounts.index(of: account)!
                self.accounts.remove(at: oldIndex)
                self.accounts.append(account)
                self.accounts.sort {
                    return $0.gameName ?? "" < $1.gameName ?? ""
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
            detailVC.saveCompleteBlock = { (account: CDAccount) in
                self.accounts.append(account)
                self.accounts.sort {
                    return $0.gameName ?? "" < $1.gameName ?? ""
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
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .onUserLoggedIn, object: nil)
        NotificationCenter.default.removeObserver(self, name: .onUserLoggedOut, object: nil)
    }
    
    // For first time after logged in
    @objc func fetchStartingData() {
        self.refreshControl.beginRefreshing()
        self.fetchAccounts(offset: 0, searchTerm: self.searchTerm)
    }
    
    @objc func clearAccounts() {
        self.accounts.removeAll()
        self.tableView.reloadData()
    }
    
    @IBAction func showSearchBar(_ sender: Any) {
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchBar.becomeFirstResponder()
    }
    
    @objc func refreshAccounts() {
        self.isFetching = false
        self.fetchAccounts(offset: 0, searchTerm: self.searchTerm, useCache: false)
    }
    
    func fetchAccounts(offset: Int, searchTerm: String, useCache: Bool = true) {
        self.isFetching = true
        let term: String? = searchTerm.isEmpty ? nil : searchTerm
        
        BackendlessAPI.sharedInstance.fetchAccounts(offset: offset, searchTerm: term, useCache: useCache) { (accounts: [CDAccount], errorMessage: String?) in
            guard errorMessage == nil else {
                self.refreshControl.endRefreshing()
                self.isFetching = false
                return
            }
            
            if (offset == 0) { // Pull to refresh
                self.accounts.removeAll()
                self.accounts = accounts
                self.tableView.reloadData()
                self.isFetching = false
            } else if accounts.isEmpty { // Reached the end of page, so no need to fetch anymore
                self.isFetching = true
            } else { // Pagination
                let startIndex: Int = self.accounts.count
                self.accounts.append(contentsOf: accounts)
                var indexPaths: [IndexPath] = []
                for i in startIndex..<self.accounts.count {
                    indexPaths.append(IndexPath(row: i, section: 0))
                }
                self.tableView.insertRows(at: indexPaths, with: .automatic)
                self.isFetching = false
            }
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
        let account: CDAccount = self.accounts[indexPath.row]
        if account.isLocked {
            let alert: UIAlertController = UIAlertController(title: nil, message: NSLocalizedString("Enter lock password", comment: "Enter lock password"), preferredStyle: .alert)
            alert.addTextField() { (textField: UITextField) in
                textField.placeholder = NSLocalizedString("Password", comment: "Password")
                textField.isSecureTextEntry = true
            }
            alert.addTextField() { (textField: UITextField) in
                textField.placeholder = NSLocalizedString("Confirm password", comment: "Confirm password")
                textField.isSecureTextEntry = true
            }
            alert.addAction(UIAlertAction(title: NSLocalizedString("Confirm", comment: "Confirm"), style: .default) { (_) in
                guard let textFields = alert.textFields,
                    textFields.count >= 2,
                    textFields[0].text == textFields[1].text,
                    account.lockPassword == nil || textFields[0].text == account.lockPassword else {
                        let hud: MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
                        hud.mode = .text
                        hud.offset = CGPoint(x: 0, y: (self.view.frame.height/2) - self.tabBarController!.tabBar.frame.height - self.navigationController!.navigationBar.frame.height)
                        hud.label.text = NSLocalizedString("Wrong lock password", comment: "Wrong lock password")
                        hud.hide(animated: true, afterDelay: 2)
                        tableView.deselectRow(at: indexPath, animated: false)
                        return
                }
                self.performSegue(withIdentifier: "showAccountDetailVC", sender: self)
                tableView.deselectRow(at: indexPath, animated: false)
            })
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel) { (_) in
                tableView.deselectRow(at: indexPath, animated: false)
            })
            self.present(alert, animated: true)
        } else {
            self.performSegue(withIdentifier: "showAccountDetailVC", sender: self)
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let hud: MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = NSLocalizedString("Loading", comment: "Loading")
            
            BackendlessAPI.sharedInstance.deleteAccount(self.accounts[indexPath.row]) { (success: Bool, errorMessage: String?) in
                hud.hide(animated: true)
                guard success else {
                    self.showAlertMessage(title: NSLocalizedString("Error", comment: "Error"), message: errorMessage ?? NSLocalizedString("Failed to delete account", comment: "Failed to delete account"))
                    return
                }
                self.accounts.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.accounts.count - 1 && !self.isFetching {
            self.fetchAccounts(offset: self.accounts.count, searchTerm: self.searchTerm)
        }
    }
}

extension AccountViewController: UISearchControllerDelegate, UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text else {
            return
        }
        self.searchTerm = searchTerm
        self.fetchAccounts(offset: 0, searchTerm: searchTerm)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.tableView.tableHeaderView = nil
        if !searchTerm.isEmpty {
            self.fetchAccounts(offset: 0, searchTerm: "")
        }
        self.searchTerm = ""
    }
}

