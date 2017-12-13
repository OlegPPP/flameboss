//
//  AddDeviceCell.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 3/16/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class AddDeviceCell : UITableViewCell
{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addDeviceButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    public func configureWithDevice(_ device: Device, added: Bool)
    {
        nameLabel.text = device.getName()
        if added
        {
            addDeviceButton.setTitle("Controller Added", for: .normal)
            addDeviceButton.isUserInteractionEnabled = false
        }
        else
        {
            addDeviceButton.setTitle("+ Add this Controller", for: .normal)
            addDeviceButton.isUserInteractionEnabled = true
        }
    }
}
