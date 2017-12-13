//
//  InfoCell.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 3/22/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class InfoCell : UITableViewCell
{
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var shadowView: UIView!
    
    public func configure(text: String, showLoadingIndicator: Bool, showBorder: Bool)
    {
        infoLabel.text = text
        
        if showLoadingIndicator { loadingIndicator.startAnimating() }
        else { loadingIndicator.stopAnimating() }
        
        if showBorder
        {
            configureShadowLayer()
        }
        else
        {
            infoLabel.textAlignment = .left
        }
    }
    
    private func configureShadowLayer()
    {
        shadowView.layer.shadowColor = UIColor.lightGray.cgColor
        shadowView.layer.shadowOffset = CGSize.zero
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.shadowRadius = 3
        shadowView.layer.cornerRadius = 5.0
        shadowView.layer.borderColor = UIColor.lightGray.cgColor
        shadowView.layer.masksToBounds = false
    }
}





