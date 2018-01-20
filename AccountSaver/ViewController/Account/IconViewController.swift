//
//  LogoViewController.swift
//  AccountSaver
//
//  Created by Avery Choke on 18/1/18.
//  Copyright © 2018 P4. All rights reserved.
//

import UIKit
import MBProgressHUD

class IconViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var imagePickerVC: UIImagePickerController = UIImagePickerController()
    
    var iconUrls: [URL] = []
    var selectedIconUrl: URL?
    var selectedIconBlock: ((URL) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hud: MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = NSLocalizedString("Fetching icons", comment: "Fetching icons")
        BackendlessAPI.sharedInstance.fetchGameIcons() { (urls: [URL]) in
            hud.hide(animated: true)
            self.iconUrls = urls
            self.collectionView.reloadData()
        }
        
        // initialize image picker
        self.imagePickerVC.modalPresentationStyle = .currentContext
        self.imagePickerVC.delegate = self
    }

    @IBAction func uploadIcon(_ sender: Any) {
        self.requestForPhotoPermission(reason: NSLocalizedString("Account Saver need to access Photo Library to upload the game icon", comment: "Account Saver need to access Photo Library to upload the game icon")) {
            self.imagePickerVC.sourceType = .photoLibrary
            self.imagePickerVC.modalPresentationStyle = .popover
            self.present(self.imagePickerVC, animated: true)
        }
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
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIconBlock?(self.iconUrls[indexPath.item])
    }
}

extension IconViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) {
            guard let image: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
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
