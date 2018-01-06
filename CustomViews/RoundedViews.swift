//
//  RoundedViews.swift
//  AccountSaver
//
//  Created by Avery Choke on 5/1/18.
//  Copyright © 2018 P4. All rights reserved.
//

import UIKit

extension UIView  {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = (newValue > 0)
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            if let borderColor = layer.borderColor {
                return UIColor(cgColor: borderColor)
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                layer.borderColor = newValue.cgColor
            }
        }
    }
}


@IBDesignable
class RoundedButton: UIButton {}

@IBDesignable
class RoundedTextField: UITextField {}

@IBDesignable
class RoundedImageView: UIImageView {}

@IBDesignable
class RoundedTextView: UITextView {}

@IBDesignable
class RoundedLabel: UILabel {}

@IBDesignable
class RoundedView: UIView {}
