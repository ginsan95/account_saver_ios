//
//  LogoCell.swift
//  AccountSaver
//
//  Created by Avery Choke on 18/1/18.
//  Copyright © 2018 P4. All rights reserved.
//

import UIKit

class IconCell: UICollectionViewCell {
    @IBOutlet weak var imageView: RoundedImageView!
    @IBOutlet weak var tickImageView: UIImageView!
    @IBOutlet weak var deleteButton: RoundedButton!
    
    var deletedCellBlock: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView.sd_setShowActivityIndicatorView(true)
        self.imageView.sd_setIndicatorStyle(.gray)
    }
    
    @IBAction func deleteIcon(_ sender: Any) {
        self.deletedCellBlock?()
    }
}
