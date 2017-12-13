//
//  AccountNavigationController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 3/6/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class AccountNavigationController : UINavigationController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setRootViewController()
    }
    
    private func setRootViewController()
    {
        let accountController = storyboard?.instantiateViewController(withIdentifier: "AccountViewController")
        let loginController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
        
        if UserDataStore.isUserLoggedIn()
        {
            self.setViewControllers([loginController!, accountController!], animated: false)
        }
        else
        {
            self.setViewControllers([loginController!], animated: false)
        }
    }
}
