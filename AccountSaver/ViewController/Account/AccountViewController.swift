//
//  AccountViewController.swift
//  AccountSaver
//
//  Created by Avery Choke on 5/1/18.
//  Copyright © 2018 P4. All rights reserved.
//

import UIKit

class AccountViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension AccountViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AccountCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AccountCell", for: indexPath) as! AccountCell
        cell.imageView.image = #imageLiteral(resourceName: "tab_account")
        cell.textLabel.text = "Test"
        cell.subLabel.text = "Test 2"
        if indexPath.row % 2 == 0 {
            cell.rightImageView.isHidden = true
        }
        return cell
    }
}
