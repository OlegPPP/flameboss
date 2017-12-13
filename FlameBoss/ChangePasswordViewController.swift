//
//  ChangePasswordViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 3/16/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class ChangePasswordViewController : FBViewController
{
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var reenterPasswordTextField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        dismissesKeyboardOnViewTap(true)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        currentPasswordTextField.becomeFirstResponder()
    }
    
    @IBAction func updatePassword()
    {
        
    }
}

extension ChangePasswordViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == currentPasswordTextField
        {
            newPasswordTextField.becomeFirstResponder()
        }
        else if textField == newPasswordTextField
        {
            reenterPasswordTextField.becomeFirstResponder()
        }
        else if textField == reenterPasswordTextField
        {
            view.endEditing(true)
        }
        
        return true
    }
}
