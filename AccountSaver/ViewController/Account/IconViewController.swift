//
//  LogoViewController.swift
//  AccountSaver
//
//  Created by Avery Choke on 18/1/18.
//  Copyright © 2018 P4. All rights reserved.
//

import UIKit
import MBProgressHUD

class IconViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var imagePickerVC: UIImagePickerController = UIImagePickerController()
    
    var iconUrls: [URL] = []
    var selectedIconUrl: URL?
    var selectedIconBlock: ((_ url: URL?) -> Void)?
    var isSelectedIconDeleted: Bool = false
    var isDeleteState: Bool = false {
        didSet {
            self.navigationItem.rightBarButtonItem?.title = self.isDeleteState ? "Done" : "Upload"
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hud: MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("Fetching icons", comment: "Fetching icons")
        BackendlessAPI.sharedInstance.fetchGameIcons() { (urls: [URL]) in
            hud.hide(animated: true)
            self.iconUrls = urls
            self.collectionView.reloadData()
        }
        
        // long click for collection view
        let longClick: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.changeToDeleteState(gesture:)))
        longClick.delegate = self
        longClick.delaysTouchesBegan = true
        self.collectionView.addGestureRecognizer(longClick)
        
        // initialize image picker
        self.imagePickerVC.modalPresentationStyle = .currentContext
        self.imagePickerVC.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (self.isMovingFromParent || self.isBeingDismissed) && self.isSelectedIconDeleted && self.selectedIconUrl == nil {
            self.selectedIconBlock?(nil)
        }
    }

    @IBAction func rightBarAction(_ sender: Any) {
        if self.isDeleteState {
            self.isDeleteState = false
        } else {
            self.requestForPhotoPermission(reason: NSLocalizedString("Account Saver need to access Photo Library to upload the game icon", comment: "Account Saver need to access Photo Library to upload the game icon")) {
                self.imagePickerVC.sourceType = .photoLibrary
                self.imagePickerVC.modalPresentationStyle = .popover
                self.present(self.imagePickerVC, animated: true)
            }
        }
    }
    
    @objc func changeToDeleteState(gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        self.isDeleteState = true
    }
}

extension IconViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.iconUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: IconCell = collectionView.dequeueReusableCell(withReuseIdentifier: "IconCell", for: indexPath) as! IconCell
        cell.imageView.sd_setImage(with: self.iconUrls[indexPath.item], placeholderImage: #imageLiteral(resourceName: "placeholder"))
        cell.tickImageView.isHidden = self.selectedIconUrl == nil || self.selectedIconUrl! != self.iconUrls[indexPath.item]
        cell.deleteButton.isHidden = !self.isDeleteState
        cell.deletedCellBlock = {
            guard let deletedIndexPath: IndexPath = self.collectionView.indexPath(for: cell) else {
                return
            }
            BackendlessAPI.sharedInstance.deleteGameIcon(url: self.iconUrls[deletedIndexPath.item])
            if let selectedIconUrl = self.selectedIconUrl, selectedIconUrl == self.iconUrls[deletedIndexPath.item] {
                self.selectedIconUrl = nil
                self.isSelectedIconDeleted = true
            }
            self.iconUrls.remove(at: deletedIndexPath.item)
            self.collectionView.deleteItems(at: [deletedIndexPath])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (!self.isDeleteState) {
            self.selectedIconBlock?(self.iconUrls[indexPath.item])
        }
    }
}

extension IconViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            guard let image: UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                self.showUploadErrorMessage()
                return
            }
            
            let hud: MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud.label.text = NSLocalizedString("Uploading", comment: "Uploading")
            
            BackendlessAPI.sharedInstance.uploadGameIcon(image){ (url: URL?, errorMessage: String?) in
                hud.hide(animated: true)
                guard let url = url else {
                    self.showUploadErrorMessage(with: errorMessage)
                    return
                }
                self.selectedIconBlock?(url)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func showUploadErrorMessage(with errorMessage: String? = nil) {
        self.showAlertMessage(title: NSLocalizedString("Error", comment: "Error"), message: errorMessage ?? NSLocalizedString("Failed to add account", comment: "Failed to add account"))
    }
}
