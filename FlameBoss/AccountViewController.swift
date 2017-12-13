//
//  AccountViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 2/23/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class AccountViewController : FBViewController
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutButton: UIButton!
    
    fileprivate var textAlertSwitch: UISwitch!
    fileprivate var tempScaleSegmentedControl: UISegmentedControl!
    fileprivate var accountCellInfos = [AccountCellInfo]()
    fileprivate var user: User!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        configure()
        tableView.reloadData()
    }
    
    private func configure()
    {
        statusBarStyle = .default
        
        logoutButton.titleLabel?.minimumScaleFactor = 0.5
        logoutButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        guard let user = FlameBossAPI.getUser() else
        {
            showLoginViewController(animated: false)
            return
        }
        self.user = user
        
        initialize()
        configureTableView()
        setTextAlertAndTempScale()
        dismissesKeyboardOnViewTap(true)
        self.tabBarController?.delegate = self
    }

    private func initialize()
    {
        initTextAlertSwitch()
        initTempScaleSegmentedControl()
        initInfoForAccountCells()
    }
    
    private func configureTableView()
    {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        removeEmptyCellsAtBottomOfTable(tableView)
    }
    
    private func initTextAlertSwitch()
    {
        let frame = CGRect(x: 0, y: 0, width: 50, height: 30)
        textAlertSwitch = UISwitch(frame: frame)
        textAlertSwitch.onTintColor = UIColor.createColor(red: 105, green: 188, blue: 41, alpha: 1.0)
        textAlertSwitch.addTarget(self, action: #selector(textAlertSwitchValueChanged), for: .valueChanged)
    }
    
    private func initTempScaleSegmentedControl()
    {
        let frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        tempScaleSegmentedControl = UISegmentedControl(items: ["C°", "F°"])
        tempScaleSegmentedControl.tintColor = UIColor.createColor(red: 105, green: 188, blue: 41, alpha: 1.0)
        tempScaleSegmentedControl.selectedSegmentIndex = 0
        tempScaleSegmentedControl.frame = frame
        tempScaleSegmentedControl.addTarget(self, action: #selector(temperatureScaleChanged), for: .valueChanged)
    }
    
    private func initInfoForAccountCells()
    {
        accountCellInfos.removeAll()
        accountCellInfos.append(AccountCellInfo(imageName: "User", title: "Username",
                                                detail: user.username))
        
        accountCellInfos.append(AccountCellInfo(imageName: "usernameIcon", title: "Email",
                                                detail: user.email))
        
        accountCellInfos.append(AccountCellInfo(imageName: "Thermo", title: "Temperature Scale",
                                                detail: "", uiElement: tempScaleSegmentedControl))
        
        accountCellInfos.append(AccountCellInfo(imageName: "padlock", title: "Change Password",
                                                detail: ""))
    }

    private func showLogOutErrorAlert(error: Error)
    {
        let message = error.localizedDescription
        let errorAlert = UIAlertController(title: "Error Logging Out", message: message, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        errorAlert.addAction(okAction)
        
        present(errorAlert, animated: true, completion: nil)
    }
    
    private func setTextAlertAndTempScale()
    {
        textAlertSwitch.setOn(user.texts_enabled, animated: false)
        tempScaleSegmentedControl.selectedSegmentIndex = user.celsius ? 0 : 1
    }
    
    func textAlertSwitchValueChanged()
    {
        user.texts_enabled = textAlertSwitch.isOn
        updateUserInfo()
    }
    
    func temperatureScaleChanged()
    {
        user.celsius = (tempScaleSegmentedControl.selectedSegmentIndex == 0)
        updateUserInfo()
    }
    
    private func updateUserInfo()
    {
        FlameBossAPI.updateUser(user: user) { (error) in
            
            if error == nil { print("user info successfully updated") }
                
            else
            { print("error updating user info: " + (error?.localizedDescription)!) }
        }
    }
    
    @IBAction func logout()
    {
        FlameBossAPI.logoutCurrentUser { (error) in
            
            if error == nil
            {
                print("user successfully logged out")
            }
            
            else
            {
                print("error occurred while logging out user: \(error!.localizedDescription)")
            }
            DispatchQueue.main.async { self.showLoginViewController(animated: true) }
        }
    }
    
    private func showLoginViewController(animated: Bool)
    {
        _ = navigationController?.popToRootViewController(animated: animated)
    }
}

extension AccountViewController : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return titleDetailCellFor(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80
    }
    
    private func titleDetailCellFor(indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTableCell") as! AccountTableCell
        
        if isRowSelectable(indexPath.row) { cell.accessoryType = .disclosureIndicator }
        
        let accountCellInfo = accountCellInfos[indexPath.row]
        
        cell.configureWithInfo(accountCellInfo)
        
        return cell
    }
    
    private func isRowSelectable(_ row: Int) -> Bool
    {
        return (row == 1 || row == 3 )
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    {
        return isRowSelectable(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 3
        {
            let signInURL = URL(string: "https://myflameboss.com/users/edit_password")
            UIApplication.shared.open(signInURL!, options: [:], completionHandler: nil)
        }
        
        else if indexPath.row == 1 { showChangeEmailController() }
        
    }
    
    private func showChangePasswordController()
    {
        let controller = storyboard?.instantiateViewController(withIdentifier: "ChangePasswordViewController")
        navigationController?.pushViewController(controller!, animated: true)
    }
    
    private func showChangeEmailController()
    {
        let controller = storyboard?.instantiateViewController(withIdentifier: "ChangeEmailViewController") as! ChangeEmailViewController
        controller.user = self.user
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension AccountViewController : UITabBarControllerDelegate
{
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool
    {
        // Prevents app from returning to the login view
        // when user double taps on this tab
        return tabBarController.selectedViewController != viewController
    }
}
