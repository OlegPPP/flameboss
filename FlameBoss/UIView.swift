//
//  UIView.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 3/20/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

extension UIView
{
    @IBInspectable var cornerRadius: CGFloat
    {
        get
        {
            return layer.cornerRadius
        }
        set
        {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat
    {
        get
        {
            return layer.borderWidth
        }
        set
        {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor?
    {
        get
        {
            return UIColor(cgColor: layer.borderColor!)
        }
        set
        {
            layer.borderColor = newValue?.cgColor
        }
    }
}
