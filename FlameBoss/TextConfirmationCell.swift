//
//  TextConfirmationCell.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 3/15/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class TextConfirmationCell : UITableViewCell
{
    @IBOutlet var textField: UITextField!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var textCodeLabel: UILabel!
    public var submitButtonCallback: (() -> ())?
    
    public func configureWithDate(_ date: Date)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY 'at' h:mm a"
        textCodeLabel.text = "We sent a code by text to you on \(dateFormatter.string(from: date))"
    }
    
    @IBAction func submitPressed()
    {
        if let callback = submitButtonCallback
        {
            callback()
        }
    }
}
