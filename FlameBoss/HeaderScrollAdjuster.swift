//
//  HeaderScrollAdjuster.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 5/3/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation
import UIKit

class HeaderScrollAdjuster : NSObject
{
    var minHeaderHeight = CGFloat(65)
    var maxHeaderHeight = CGFloat(240)
    
    private var headerImageView: UIImageView!
    private var headerHeightConstraint: NSLayoutConstraint!
    private var headerDetailLabel: UILabel!
    private var previousScrollOffset = CGFloat(0)
    
    init(headerImageView: UIImageView, headerHeightConstraint: NSLayoutConstraint, headerDetailLabel: UILabel)
    {
        super.init()
        
        self.headerImageView = headerImageView
        self.headerHeightConstraint = headerHeightConstraint
        self.headerDetailLabel = headerDetailLabel
        adjustHeaderHeight()
        maxHeaderHeight = headerHeightConstraint.constant
    }
    
    public func adjustHeaderHeight()
    {
        headerHeightConstraint.constant = headerHeight()
    }
    
    private func headerHeight() -> CGFloat
    {
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        
        return screenHeight * CGFloat(0.36)
    }
    
    public func updateHeaderForScrollView(_ scrollView: UIScrollView)
    {
        let yOffset = scrollView.contentOffset.y
        
        var headerTransform = CATransform3DIdentity
        let scaleFactor:CGFloat = (yOffset / headerImageView.bounds.height) * 1.5
        
        if yOffset <= 0
        {
            headerTransform = CATransform3DScale(headerTransform, 1.0 + -scaleFactor, 1.0 + -scaleFactor, 0)
            
            headerImageView.layer.transform = headerTransform
        }
        
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        let contentHeight = scrollView.contentSize.height
        if (contentHeight < (screenHeight + 330) ) { return }
        
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        
        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;
        
        let isScrollingUp = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingDown = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        
        var newHeight = self.headerHeightConstraint.constant
        if isScrollingUp
        {
            newHeight = max(self.minHeaderHeight, self.headerHeightConstraint.constant - abs(scrollDiff) * 0.9)
        }
        else if isScrollingDown && yOffset <= maxHeaderHeight
        {
            newHeight = min(self.maxHeaderHeight, self.headerHeightConstraint.constant + abs(scrollDiff) * 0.9)
        }
        
        self.headerHeightConstraint.constant = newHeight
        
        let value = maxHeaderHeight * 1.38
        let percentage = ((value - yOffset) / 100)
        headerDetailLabel.alpha = ( (100 - yOffset)/100 )
        
        headerImageView.alpha = percentage
        
        self.previousScrollOffset = scrollView.contentOffset.y
    }
}
