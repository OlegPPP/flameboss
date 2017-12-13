//
//  CookTitleNotesViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 7/3/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit
import RichEditorView

class CookTitleNotesViewController : FBViewController
{
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var richTextEditor: RichEditorView!
    
    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    public var cookTitleAndNotesUpdated: ((Cook) -> ())!
    
    public var htmlText: String = ""
    
    public var cook: Cook?
    public var focus = Focus.None
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        configForFocus()
    }
    
    private func configForFocus()
    {
        switch focus {
        case .None:
            break
            
        case .Title:
            titleTextField.becomeFirstResponder()
            
        case.Notes:
            richTextEditor.focus()
        }
    }
    
    private func configure()
    {
        if let cook = cook
        {
            let title = cook.title ?? ""
            titleTextField.text = cleanHtmlForDisplay(htmlString: title)
        }
        
        configureRichTextEditor()
        addToolbar()
        
        dismissesKeyboardOnViewTap(true)
        statusBarStyle = .default
        
        addKeyboardWillShowNotification()
        addKeyboardWillHideNotification()
    }
    
    private func configureRichTextEditor()
    {
        richTextEditor.isScrollEnabled = true
        if let cook = cook
        {
            let notes = cook.notes ?? ""
            richTextEditor.html = cleanHtmlForDisplay(htmlString: notes)
        }
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
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        {
            DispatchQueue.main.async
            {
                if !self.titleTextField.isEditing
                {
                    self.titleTopConstraint.constant = -(45+16)
                    self.bottomConstraint.constant += keyboardSize.height - 44
                    
                    UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
                        self.view.layoutIfNeeded()
                    }, completion: nil)
                }
            }
        }
    }
    
    private func addToolbar()
    {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        self.richTextEditor.inputAccessoryView = toolbar
        toolbar.options = toolbarOptions()
        toolbar.editor = self.richTextEditor
    }
    
    private func toolbarOptions() -> [RichEditorDefaultOption]
    {
        let options = [RichEditorDefaultOption.bold, RichEditorDefaultOption.italic, RichEditorDefaultOption.strike,
                       RichEditorDefaultOption.underline, RichEditorDefaultOption.orderedList, RichEditorDefaultOption.unorderedList, RichEditorDefaultOption.undo, RichEditorDefaultOption.redo]
        
        return options
    }
    
    func keyboardWillHide(notification: NSNotification)
    {
        DispatchQueue.main.async
        {
            if !self.titleTextField.isEditing
            {
                self.titleTopConstraint.constant = 8
                self.bottomConstraint.constant = 8
                
                UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }
    
    @IBAction func save()
    {
        if self.cook == nil { return }
        
        let title = titleTextField.text ?? ""
        var notes = richTextEditor.html
        if notes == "<br>" { notes = "" }
        
        let serverTitle = cleanHtmlForAPI(htmlString: title)
        let serverNotes = cleanHtmlForAPI(htmlString: notes)
        
        FlameBossAPI.updateCook(cookID: cook!.id, title: serverTitle, notes: serverNotes, keep: true) { (error) in
            if error == nil
            {
                if title != "" { self.cook?.title = title }
                self.cook?.notes = notes
                
                self.cook?.notes = notes
                
                if self.cookTitleAndNotesUpdated != nil {
                    self.cookTitleAndNotesUpdated(self.cook!)
                }
            }
        }
    }
    
    private func cleanHtmlForAPI(htmlString: String) -> String
    {
        return htmlString.replacingOccurrences(of: "&", with: "%26")
    }
    
    private func cleanHtmlForDisplay(htmlString: String) -> String
    {
        return htmlString.replacingOccurrences(of: "%26", with: "&")
    }
}

public enum Focus
{
    case None
    case Title
    case Notes
}
