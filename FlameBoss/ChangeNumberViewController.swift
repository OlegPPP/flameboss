//
//  ChangeNumberViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 5/22/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class ChangeNumberViewController : FBViewController
{
    @IBOutlet weak var currentNumberTextField: UITextField!
    @IBOutlet weak var newNumberTextField: UITextField!
    @IBOutlet weak var reenterNumberTextField: UITextField!
    private var user: User?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        statusBarStyle = .default
        dismissesKeyboardOnViewTap(true)
        
        guard let user = FlameBossAPI.getUser() else { return }
        
        self.user = user
        currentNumberTextField.text = (user.phone.isEmpty) ? "not provided" : user.phone
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        newNumberTextField.becomeFirstResponder()
    }
    
    @IBAction func updateNumber()
    {
        guard var user = self.user else { return }
        
        guard isPhoneNumberValid() else { showErrorAlertWithMessage("Please enter a valid phone number"); return }
        
        guard doNumbersMatch() else { showErrorAlertWithMessage("Phone numbers do not match"); return }
        
        user.phone = newNumberTextField.text!
        FlameBossAPI.updateUser(user: user) { (error) in
            if error == nil { self.showSuccessAlert() }
            else  { self.showErrorAlertWithMessage(error!.localizedDescription) }
        }
    }
    
    private func showSuccessAlert()
    {
        let alert = UIAlertController(title: "Update Successful", message: "Your phone number was successfully updated", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { (UIAlertAction) in
            super.back()
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func isPhoneNumberValid() -> Bool
    {
        if let _ = UInt(newNumberTextField.text!) { return true }
        
        return false
    }
    
    private func doNumbersMatch() -> Bool
    {
        return newNumberTextField.text == reenterNumberTextField.text
    }
    
    private func showErrorAlertWithMessage(_ message: String)
    {
        let errorAlert = UIAlertController(title: "Error Updating Number", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        errorAlert.addAction(okAction)
        
        present(errorAlert, animated: true, completion: nil)
    }
}

extension ChangeNumberViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == currentNumberTextField
        {
            newNumberTextField.becomeFirstResponder()
        }
        else if textField == newNumberTextField
        {
            reenterNumberTextField.becomeFirstResponder()
        }
        else if textField == reenterNumberTextField
        {
            view.endEditing(true)
        }
        
        return true
    }
}
