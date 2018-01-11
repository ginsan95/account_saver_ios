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
    
    @objc func fetchAccounts() {
        BackendlessAPI.sharedInstance.fetchAccounts { (accounts: [Account], error: Error?) in
            guard error == nil else {
                self.refreshControl.endRefreshing()
                return
            }
            
            self.accounts = accounts
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showAccountDetailVC", let detailVC: AccountDetailViewController = segue.destination as? AccountDetailViewController, let indexPath: IndexPath = self.collectionView.indexPathsForSelectedItems?.first {
            detailVC.account = self.accounts[indexPath.item]
            detailVC.isEditMode = false
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
