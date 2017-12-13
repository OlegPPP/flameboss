//
//  FBViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 2/23/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class FBViewController : UIViewController
{
    private var shouldDismissKeyboardOnViewTap = false
    
    public var statusBarStyle : UIStatusBarStyle = .lightContent
    {
        didSet { setNeedsStatusBarAppearanceUpdate() }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        addViewTapGestureListener()
    }
    
    public func headerHeight() -> CGFloat
    {
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        
        return screenHeight * CGFloat(0.36)
    }
    
    func removeEmptyCellsAtBottomOfTable(_ tableView: UITableView)
    {
        tableView.tableFooterView = UIView()
    }
    
    private func addViewTapGestureListener()
    {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func viewTapped()
    {
        if shouldDismissKeyboardOnViewTap
            { view.endEditing(true) }
    }
    
    func dismissesKeyboardOnViewTap(_ shouldDismiss: Bool)
    {
        shouldDismissKeyboardOnViewTap = true
    }
    
    @IBAction func back()
    {
        if let navController = navigationController
        {
            navController.popViewController(animated: true)
        }
        else
        {
            dismiss(animated: true, completion: nil)
        }
    }
}
