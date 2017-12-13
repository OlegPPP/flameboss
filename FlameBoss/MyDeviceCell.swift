//
//  MyDeviceCell.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 3/16/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class MyDeviceCell : UITableViewCell
{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editNameButton: UIButton!
    @IBOutlet weak var wifiButton: UIButton!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    public func configureWithDevice(_ device: Device)
    {
        let controllerName = device.getName()
        nameLabel.text = controllerName
    }
    
    public func addTagForButtons(_ tag: Int)
    {
        editNameButton.tag = tag
        wifiButton.tag = tag
        soundButton.tag = tag
        removeButton.tag = tag
    }
}
