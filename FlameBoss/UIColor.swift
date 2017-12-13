//
//  UIColor.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 2/27/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

extension UIColor
{
    public static func createColor(red: Int, green: Int, blue: Int, alpha: CGFloat) -> UIColor
    {
        let r = CGFloat(red)/255.0
        let g = CGFloat(green)/255.0
        let b = CGFloat(blue)/255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
}
