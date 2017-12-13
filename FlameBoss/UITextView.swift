//
//  UITextView.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 7/5/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit
import Foundation

extension UITextView
{
    public func displayHtmlText(_ htmlText: String?)
    {
        if let text = htmlText
        {
            DispatchQueue.main.async
            {
                let attrString = self.attributtedStringFromHtml(text)
                self.attributedText = attrString
            }
        }
    }
    
    private func attributtedStringFromHtml(_ htmlString: String) -> NSAttributedString?
    {
        let fontStyle = "<style>body{font-family:'-apple-system'; font-size: 21;}</style>"
        let newHtmlString = htmlString.appending(fontStyle)
        
        let htmlData = NSString(string: newHtmlString).data(using: String.Encoding.unicode.rawValue)
        
        if htmlData == nil { return nil }
        
        let attributedString = try? NSAttributedString(data: htmlData!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
        
        return attributedString
    }
}
