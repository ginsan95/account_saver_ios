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
    @IBOutlet weak var collectionView: UICollectionView!
    var refreshControl: UIRefreshControl!

    var accounts: [Account] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(fetchAccounts), for: UIControlEvents.valueChanged)
        self.collectionView.addSubview(refreshControl)
        
        self.refreshControl.beginRefreshing()
        self.fetchAccounts()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showAccountDetailVC" {
            guard let detailVC: AccountDetailViewController = segue.destination as? AccountDetailViewController, let indexPath: IndexPath = self.collectionView.indexPathsForSelectedItems?.first else {
                return
            }
            detailVC.viewType = .view
            detailVC.account = self.accounts[indexPath.item]
            detailVC.saveCompleteBlock = { (account: Account) in
                let oldIndex = self.accounts.index(of: account)!
                self.accounts.remove(at: oldIndex)
                self.accounts.append(account)
                self.accounts.sort {
                    return $0.gameName < $1.gameName
                }
                
                let index = self.accounts.index(of: account)
                if let index = index {
                    self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                } else {
                    self.collectionView.reloadData()
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
                    self.collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
                } else {
                    self.collectionView.reloadData()
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
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
}

extension AccountViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.accounts.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AccountCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AccountCell", for: indexPath) as! AccountCell
        let account = self.accounts[indexPath.row]
        
        cell.imageView.sd_setImage(with: account.gameIconUrl, placeholderImage: #imageLiteral(resourceName: "placeholder"))
        cell.textLabel.text = account.gameName
        cell.subLabel.text = account.encrytedUsername
        cell.rightImageView.isHidden = !account.isLocked
        
        return cell
    }
}
