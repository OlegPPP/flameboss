//
//  FBTabBarController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 2/27/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class FBTabBarController : UITabBarController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tabBar.tintColor = UIColor.createColor(red: 105, green: 188, blue: 0, alpha: 1)
        tabBar.backgroundColor = UIColor.white
        tabBar.isTranslucent = false
        
        let imageNames = ["icon_normal_home", "icon_normal_controllers", "icon_normal_history", "icon_normal_account"]
        let titles = ["Home", "Controllers", "History", "Account"]
        
        for i in 0 ..< (viewControllers?.count)!
        {
            let controller = viewControllers?[i]
            let title = titles[i]
            let image = UIImage(named: imageNames[i])
            controller?.tabBarItem  = UITabBarItem(title: title, image: image, tag: 0)
        }
    }
}
