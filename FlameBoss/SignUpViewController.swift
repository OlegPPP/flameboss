//
//  SignUpViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 3/2/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class SignUpViewController : FBViewController
{
    @IBOutlet weak var signingUpIndicatorView: UIView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var termsOfUseView: UIView!
    @IBOutlet weak var alreadyHaveAccountButton: UIButton!
    
    private var isFirstAppearance: Bool = true
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configure()
    }
    
    private func configure()
    {
        signingUpIndicatorView.alpha = 0.0
        dismissesKeyboardOnViewTap(true)
        
        headerHeightConstraint.constant = super.headerHeight()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if isFirstAppearance { usernameTextField.becomeFirstResponder() }
        isFirstAppearance = false
    }
    
    private func tempScaleByLocale() -> TempScale
    {
        return NSLocale.current.usesMetricSystem ? .Celsius : .Fahrenheit
    }
    
    func textAlertSwitchValueChanged()
    {
        view.endEditing(true)
    }
    
    @IBAction func alreadyHaveAccount()
    {
        showLoginViewController()
    }
    
    private func showSigningUpIndicatorView(animated: Bool)
    {
        if animated
        {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
                self.signingUpIndicatorView.alpha = 1.0
            }, completion: nil)
        }
        else { signingUpIndicatorView.alpha = 1.0 }
    }
    
    private func hideSigningUpIndicatorView(animated: Bool)
    {
        if animated
        {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
                self.signingUpIndicatorView.alpha = 0.0
            }, completion: nil)
        }
            
        else { signingUpIndicatorView.alpha = 0.0 }
    }
    
    @IBAction func signUp()
    {
        let username = usernameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        showSigningUpIndicatorView(animated: true)
        view.isUserInteractionEnabled = false
        
        FlameBossAPI.signUpUser(username: username, email: email, password: password) { (error) in
            DispatchQueue.main.async
            {
                self.hideSigningUpIndicatorView(animated: true)
                self.view.isUserInteractionEnabled = true
                
                guard error == nil else
                {
                    self.showErrorAlertWithMessage(error!.localizedDescription)
                    return
                }
                
                print("User successfully signed up")
                self.updateUserInfo()
            }
        }
    }
    
    private func updateUserInfo()
    {
        guard var user = FlameBossAPI.getUser() else { return }
        
        user.celsius = tempScaleByLocale() == .Celsius ? true : false
        FlameBossAPI.updateUser(user: user) { (error) in
            
            if UserDataStore.isFirstTimeUsingApp()
            {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
                UserDataWriter.setFirstTimeUsingApp(false)
            }
                
            else
            {
                DispatchQueue.main.async {
                    self.showAccountViewController()
                }
            }
        }
    }
    
    @IBAction func termsOfUse()
    {
        let termsURL = URL(string: "https://myflameboss.com/terms")
        UIApplication.shared.open(termsURL!, options: [:], completionHandler: nil)
    }
    
    private func showAccountViewController()
    {
        let accountController = storyboard?.instantiateViewController(withIdentifier: "AccountViewController")
        navigationController?.pushViewController(accountController!, animated: true)
    }
    
    private func showLoginViewController()
    {
        navigationController?.popViewController(animated: true)
    }
    
    private func showErrorAlertWithMessage(_ message: String)
    {
        let errorAlert = UIAlertController(title: "Error Signing Up", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        errorAlert.addAction(okAction)
        
        present(errorAlert, animated: true, completion: nil)
    }
}

extension SignUpViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == usernameTextField
        {
            emailTextField.becomeFirstResponder()
        }
        else if textField == emailTextField
        {
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField
        {
            view.endEditing(true)
        }
        
        return true
    }
}
