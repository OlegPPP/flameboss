//
//  AccountCellInfo.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 3/15/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation
import UIKit

struct AccountCellInfo
{
    var imageName: String
    var title: String
    var detail: String
    var uiElement: UIView?
    
    init(imageName: String, title: String, detail: String, uiElement: UIView? = nil)
    {
        self.imageName = imageName
        self.title = title
        self.detail = detail
        self.uiElement = uiElement
    }
}
