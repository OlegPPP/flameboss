//
//  ChangeEmailViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 5/22/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class ChangeEmailViewController : FBViewController
{
    @IBOutlet weak var currentEmailTextField: UITextField!
    @IBOutlet weak var newEmailTextField: UITextField!
    @IBOutlet weak var reenterEmailTextField: UITextField!
    private var didSetEmail: Bool = false
    
    public var user: User?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        statusBarStyle = .default
        dismissesKeyboardOnViewTap(true)
        
        guard let user = FlameBossAPI.getUser() else { return }
        if !user.email.isEmpty
        {
            currentEmailTextField.text = user.email
            didSetEmail = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if didSetEmail == true { newEmailTextField.becomeFirstResponder() }
            
        else { currentEmailTextField.becomeFirstResponder() }
    }
    
    @IBAction func updateEmail()
    {
        guard var user = self.user else { return }
        
        guard isEmailValid() else { showErrorAlertWithMessage("Please enter a valid email address"); return }
        guard doEmailsMatch() else { showErrorAlertWithMessage("Emails do not match"); return }
        
        user.email = newEmailTextField.text!
        FlameBossAPI.updateUser(user: user) { (error) in
            
            if error == nil { self.showSuccessAlert() }
                
            else { self.showErrorAlertWithMessage(error!.localizedDescription) }
        }
    }
    
    private func showSuccessAlert()
    {
        let alert = UIAlertController(title: "Confirm Email", message: "We sent a confirmation to your new email. Once your new email is confirmed, it will show up on your account", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
            super.back()
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func isEmailValid() -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: newEmailTextField.text)
    }
    
    private func doEmailsMatch() -> Bool
    {
        return newEmailTextField.text == reenterEmailTextField.text
    }
    
    private func showErrorAlertWithMessage(_ message: String)
    {
        let errorAlert = UIAlertController(title: "Error Updating Email", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        errorAlert.addAction(okAction)
        
        present(errorAlert, animated: true, completion: nil)
    }
}

extension ChangeEmailViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == currentEmailTextField
        {
            newEmailTextField.becomeFirstResponder()
        }
        else if textField == newEmailTextField
        {
            reenterEmailTextField.becomeFirstResponder()
        }
        else if textField == reenterEmailTextField
        {
            view.endEditing(true)
        }
        
        return true
    }
}
