//
//  TextRegionScrollViewAdjuster.swift
//
//  Created by Kevoye Boswell on 12/25/16.
//  Copyright © 2016 TreePie. All rights reserved.
//

import UIKit

class TextRegionScrollViewAdjuster : NSObject, UITextFieldDelegate, UITextViewDelegate
{
    var scrollView: UIScrollView!
    
    private var yLocationForTextRegionWithFocus: Float!
    private var heightForTextRegionWithFocus: Float!
    private var keyboardHeight: CGFloat!
    private var scrollViewOffset_BeforeItIsAdjusted:CGPoint!
    
    var textFieldBeganEditing: ((UITextField) -> ())!
    var textFieldEndedEditing: ((UITextField) -> ())!
    
    var textViewBeganEditing: ((UITextView) -> ())!
    var textViewEndedEditing: ((UITextView) -> ())!
    
    init(scrollView: UIScrollView, textField: UITextField? = nil, textView: UITextView? = nil)
    {
        self.scrollView = scrollView
        
        super.init()
        
        if textField != nil
        {
            textField?.delegate = self
        }
        if textView != nil
        {
            textView?.delegate = self
        }
        
        addKeyboardWillShowNotification()
        addKeyboardWillHideNotification()
        recordScrollViewContentOffset()
    }
    
    private func addKeyboardWillShowNotification()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: .UIKeyboardWillShow, object: nil)
    }
    
    private func addKeyboardWillHideNotification()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]
            as? NSValue)?.cgRectValue
        {
            keyboardHeight = keyboardSize.height
            
            adjustScrollViewToShowTextRegionIfNecessary()
        }
    }
    
    private func adjustScrollViewToShowTextRegionIfNecessary()
    {
        guard let keyboardHeight = keyboardHeight
            else { return }
        
        if let textRegionYLocation = yLocationForTextRegionWithFocus
        {
            let tableHeight = scrollView.superview?.frame.size.height
            let tableHeightWithOffset = tableHeight! - scrollView.contentOffset.y
            let heightWithKeyboardOnScreen = Float(tableHeightWithOffset - keyboardHeight)
            let aboveThreshold = textRegionYLocation + heightForTextRegionWithFocus
            
            if aboveThreshold > heightWithKeyboardOnScreen
            {
                let offset = (aboveThreshold - heightWithKeyboardOnScreen) + 20
                scrollView.setContentOffset(CGPoint(x: 0, y: Int(offset)), animated: true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        scrollView.setContentOffset(scrollViewOffset_BeforeItIsAdjusted, animated: true)
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        recordScrollViewContentOffset()
        let focusedTextFieldFrame = textField.superview?.convert(textField.frame, to:
            scrollView.superview)
        yLocationForTextRegionWithFocus = Float((focusedTextFieldFrame?.origin.y)!)
        heightForTextRegionWithFocus =  Float(textField.frame.size.height)
        
        if self.textFieldBeganEditing != nil
        {
            textFieldBeganEditing(textField)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if self.textFieldEndedEditing != nil
        {
            textFieldEndedEditing(textField)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        recordScrollViewContentOffset()
        let focusedTextFieldFrame = textView.superview?.convert(textView.frame, to:
            scrollView.superview)
        yLocationForTextRegionWithFocus = Float((focusedTextFieldFrame?.origin.y)!)
        heightForTextRegionWithFocus =  Float(textView.frame.size.height)
        
        adjustScrollViewToShowTextRegionIfNecessary()
        
        if self.textViewBeganEditing != nil
        {
            textViewBeganEditing(textView)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textViewEndedEditing != nil
        {
            textViewEndedEditing(textView)
        }
    }
    
    private func recordScrollViewContentOffset()
    {
        scrollViewOffset_BeforeItIsAdjusted = scrollView.contentOffset
    }
}
