//
//  LoginViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 3/2/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class LoginViewController : FBViewController
{
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginIndicatorView: UIView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var skipButton: UIButton!


    override func viewDidLoad()
    {
        super.viewDidLoad()
        configure()
        
        
    }
    
    private func configure()
    {
        skipButton.isHidden = !UserDataStore.isFirstTimeUsingApp()
        loginIndicatorView.alpha = 0.0
        dismissesKeyboardOnViewTap(true)
        headerHeightConstraint.constant = super.headerHeight()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if FlameBossAPI.getUser() != nil
        {
            showAccountViewController(animated: false)
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    @IBAction func forgotPassword()
    {
        let passwordURL = URL(string: "https://myflameboss.com/users/secret/new")
        UIApplication.shared.open(passwordURL!, options: [:], completionHandler: nil)
    }
    
    @IBAction func login()
    {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        showLoginIndicatorView(animated: true)
        view.isUserInteractionEnabled = false
        
        
        FlameBossAPI.loginUser(username: username, password: password) { (error) in
            
            DispatchQueue.main.async
            {
                self.hideLoginIndicatorView(animated: true)
                self.view.isUserInteractionEnabled = true
                
                guard error == nil else
                {
                    self.showAlertWithError(error!)
                    return
                }
                
                if UserDataStore.isFirstTimeUsingApp()
                {
                    self.dismiss(animated: true, completion: nil)
                    UserDataWriter.setFirstTimeUsingApp(false)
                }
                
                else
                {
                    self.showAccountViewController(animated: true)
                    self.clearTextFieldsAndHideKeyboard()
                }
            }
        }
    }
    
    private func clearTextFieldsAndHideKeyboard()
    {
        usernameTextField.text = ""
        passwordTextField.text = ""
        
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    private func showAccountViewController(animated: Bool)
    {
        let accountController = storyboard?.instantiateViewController(withIdentifier: "AccountViewController")
        navigationController?.pushViewController(accountController!, animated: animated)
    }
    
    private func showLoginIndicatorView(animated: Bool)
    {
        if animated
        {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
                self.loginIndicatorView.alpha = 1.0
            }, completion: nil)
        }
        else { loginIndicatorView.alpha = 1.0 }
    }
    
    private func hideLoginIndicatorView(animated: Bool)
    {
        if animated
        {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                self.loginIndicatorView.alpha = 0.0
            }, completion: nil)
        }
        
        else { loginIndicatorView.alpha = 0.0 }
    }
    
    private func showAlertWithError(_ error: Error)
    {
        let message = error.localizedDescription
        let errorAlert = UIAlertController(title: "Error Logging In", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        errorAlert.addAction(okAction)
        
        present(errorAlert, animated: true, completion: nil)
    }
    
    @IBAction func signUp()
    {
        showSignUpViewController()
        clearTextFieldsAndHideKeyboard()
    }
    
    private func showSignUpViewController()
    {
        let signUpController = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        navigationController?.pushViewController(signUpController, animated: true)
    }
    
    @IBAction func skip()
    {
        UserDataWriter.setFirstTimeUsingApp(false)
        dismiss(animated: true, completion: nil)
    }
}

extension LoginViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == usernameTextField
        {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField
        {
            view.endEditing(true)
            login()
        }
        
        return true
    }
}
