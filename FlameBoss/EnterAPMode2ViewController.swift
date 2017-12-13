//
//  EnterAPMode2ViewController.swift
//  FlameBoss
//
//  Created by Roger Collins on 8/24/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class EnterAPMode2ViewController : UIViewController
{
    @IBOutlet weak var instructionLabel: UILabel!

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

        let a = NSMutableAttributedString(string:
            "After switching to AP Mode\n" +
            "your controller will show ",attributes: normalAttrs)
        a.append(NSMutableAttributedString(string: "WiFi Status", attributes: boldAttrs))
        a.append(NSMutableAttributedString(string:
            "\nalong with the name of its\n" +
            "WiFi network (its SSID).",
                                          attributes: normalAttrs))

        instructionLabel.attributedText = a
    }
    
    @IBAction func next(_ sender: Any) {
        if nextPage != nil { nextPage() }
    }
}
