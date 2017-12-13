//
//  AccountTableCell.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 3/15/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class AccountTableCell : UITableViewCell
{
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var uiElementView: UIView!
    
    func configureWithInfo(_ info: AccountCellInfo)
    {
        infoImageView.image = UIImage(named: info.imageName)
        titleLabel.text = info.title
        detailLabel.text = info.detail
        
        if let element = info.uiElement
        {
            hasUIElement(true)
            addUIElement(element)
        }
        else
        {
            hasUIElement(false)
        }
        
        if info.detail == ""
        {
            detailLabel.isHidden = true
            titleLabel.textColor = UIColor.black
            titleLabel.font = UIFont.systemFont(ofSize: 19)
            
            let titleLabelSuperView = titleLabel.superview
            titleTopConstraint.constant = ((titleLabelSuperView?.frame.height)! - titleLabel.frame.height) / 2
        }
    }
    
    private func hasUIElement(_ hasElement: Bool)
    {
        if hasElement
        {
            uiElementView.isHidden = false
            viewLeadingConstraint.constant = 90
            titleLabel.textColor = UIColor.black
            titleLabel.font = UIFont.systemFont(ofSize: 19)
            detailLabel.textColor = UIColor.lightGray
            detailLabel.font = UIFont.systemFont(ofSize: 14)
        }
        else
        {
            uiElementView.isHidden = true
            viewLeadingConstraint.constant = 16
            titleLabel.textColor = UIColor.lightGray
            titleLabel.font = UIFont.systemFont(ofSize: 14)
            detailLabel.textColor = UIColor.black
            detailLabel.font = UIFont.systemFont(ofSize: 19)
        }
    }
    
    func addUIElement(_ element: UIView)
    {
        removeAllViewsFromElementView()
        let width = element.frame.width, height = element.frame.height
        let frame = CGRect(x: 0, y: (uiElementView.frame.height - height)/2, width: width, height: height)
        
        element.frame = frame
        uiElementView.addSubview(element)
    }
    
    private func removeAllViewsFromElementView()
    {
        for view in uiElementView.subviews
        {
            view.removeFromSuperview()
        }
    }
}
