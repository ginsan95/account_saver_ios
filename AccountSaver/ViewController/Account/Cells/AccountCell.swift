//
//  AccountCell.swift
//  AccountSaver
//
//  Created by Avery Choke on 6/1/18.
//  Copyright © 2018 P4. All rights reserved.
//

import UIKit

class AccountCell: UITableViewCell {
    @IBOutlet weak var logoImageView: RoundedImageView!
    @IBOutlet weak var mainTextLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.logoImageView.sd_setShowActivityIndicatorView(true)
        self.logoImageView.sd_setIndicatorStyle(.gray)
    }
}
