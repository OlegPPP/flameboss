//
//  EnterAPModeViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 7/18/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class EnterAPModeViewController : UIViewController
{
    @IBOutlet weak var instruction1Label: UILabel!
    @IBOutlet weak var instruction2Label: UILabel!
    @IBOutlet weak var instruction3Label: UILabel!
    
    var nextPage: (() -> ())!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configureInstructionLabels()
    }
    
    private func configureInstructionLabels()
    {
        let normalAttrs = [NSFontAttributeName : UIFont.systemFont(ofSize: 16.0)]
        let boldAttrs = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 16.0)]

        let a = NSMutableAttributedString(string: "On your controller, press MENU until it\nshows ", attributes: normalAttrs)
        a.append(NSMutableAttributedString(string: "WiFi Menu", attributes: boldAttrs))
        a.append(NSMutableAttributedString(string: ".\n\nPress UP to show ", attributes: normalAttrs))
        a.append(NSMutableAttributedString(string: "[Enter]", attributes: boldAttrs))
        a.append(NSMutableAttributedString(string: " on 2nd line.\n\nPress MENU until it shows ", attributes: normalAttrs))
        a.append(NSMutableAttributedString(string: "WiFi Mode", attributes: boldAttrs))
        a.append(NSMutableAttributedString(string: ".\n\nPress UP to show ", attributes: normalAttrs))
        a.append(NSMutableAttributedString(string: "[Access Point]", attributes: boldAttrs))
        a.append(NSMutableAttributedString(string: "\non 2nd line.\n\nPress MENU to start AP Mode.", attributes: normalAttrs))

        instruction1Label.attributedText = a
    }
    
    @IBAction func next(_ sender: Any) {
        if nextPage != nil { nextPage() }
    }
}
