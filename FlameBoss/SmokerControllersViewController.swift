//
//  SmokerControllersViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 2/23/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class SmokerControllersViewController : FBViewController
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addControllerButton: UIButton!
    
    public var viewModel: SmokerControllersViewModel!
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var headerDetailLabel: UILabel!
    
    fileprivate var headerScrollAdjuster: HeaderScrollAdjuster!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configure()
    }
    
    private func configure()
    {
        headerScrollAdjuster = HeaderScrollAdjuster(headerImageView: headerImageView,
                        headerHeightConstraint: headerHeightConstraint, headerDetailLabel: headerDetailLabel)
        
        viewModel = SmokerControllersViewModel(updateAppearanceCallback: reloadTableOnMainThread)
        viewModel.editNameCallback = editName(_:)
        viewModel.editWifiCallback = editWifi
        viewModel.editSoundCallback = editSound
        viewModel.removeDeviceCallback = removeDevice
        viewModel.addDeviceCallback = addDevice(_:)
        
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        
        let infoCellNib = UINib(nibName: "InfoCell", bundle: nil)
        tableView.register(infoCellNib, forCellReuseIdentifier: "InfoCell")
        
        addControllerButton.titleLabel?.minimumScaleFactor = 0.5
        addControllerButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.viewModel.refreshDevices()
    }
    
    private func reloadTableOnMainThread()
    {
        DispatchQueue.main.async
            { self.tableView.reloadData() }
    }
    
    @IBAction func apModeSetup()
    {
        let storyboard = UIStoryboard(name: "APModeSetup", bundle: nil)
        let apModeSetupController = storyboard.instantiateViewController(withIdentifier: "APModeSetupViewController")
        
        present(apModeSetupController, animated: true, completion: nil)
    }
    
    @IBAction func addController()
    {
        addDevice(nil)
    }
    
    func addDevice(_ device: Device?)
    {
        if viewModel.isUserLoggedIn() { showAddDeviceViewController(device: device) }
        else { showLoginAlert() }
    }
    
    private func showLoginAlert()
    {
        let title = "Login"
        let message = "You must be logged in to add a controller"
        let loginAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let loginAction = UIAlertAction(title: "Login", style: .default) { (alertAction) in
            self.tabBarController?.selectedIndex = 3
        }
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        loginAlert.addAction(loginAction)
        loginAlert.addAction(okAction)
        
        present(loginAlert, animated: true, completion: nil)
    }
    
    private func showAddDeviceViewController(device: Device?)
    {
        let controller = storyboard?.instantiateViewController(withIdentifier: "AddDeviceViewController") as! AddDeviceViewController
        if let d = device { controller.device = d }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func editName(_ device: Device)
    {
        showAlertToEnterControllerName(controller: device)
    }
    
    func editWifi(_ device: Device)
    {
        let wifiConfigController = storyboard?.instantiateViewController(withIdentifier: "ConfigureWifiViewController") as! ConfigureWifiViewController
        wifiConfigController.smokerController = device
        navigationController?.pushViewController(wifiConfigController, animated: true)
    }
    
    func editSound(_ device: Device)
    {
        let soundConfigController = storyboard?.instantiateViewController(withIdentifier: "ConfigureSoundViewController") as! ConfigureSoundViewController
        soundConfigController.smokerController = device
        navigationController?.pushViewController(soundConfigController, animated: true)
    }
    
    func removeDevice(_ device: Device)
    {
        showAlertToRemoveController(device)
    }
    
    func showAlertToEnterControllerName(controller: Device)
    {
        let message = "Enter a name for your controller"
        let nameAlert = UIAlertController(title: "Name Your Controller", message: message, preferredStyle: .alert)
        
        nameAlert.addTextField(configurationHandler: nil)
        
        nameAlert.textFields?[0].placeholder = controller.getName()
        nameAlert.textFields?[0].autocapitalizationType = .words
        nameAlert.textFields?[0].returnKeyType = .done
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        { (UIAlertAction) in
            
            let enteredName = nameAlert.textFields?[0].text
            if (enteredName?.characters.count)! > 0
            {
                FlameBossAPI.updateDeviceName(deviceID: controller.id, newName: enteredName!, completion: { (error) in
                    if error == nil { self.viewModel.refreshDevices() }
                    else
                    {
                        self.showAlert(title: "Error Updating Name", message: (error?.localizedDescription)!)
                    }
                })
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        nameAlert.addAction(okAction)
        nameAlert.addAction(cancelAction)
        
        present(nameAlert, animated: true, completion: nil)
    }
    
    private func showAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func showAlertToRemoveController(_ controller: Device)
    {
        let title = "Remove \(controller.getName())?"
        let message = "This will also remove the cooks from this controller from your cook history. Are you sure you " +
        "want to remove \(controller.getName()) from your account?"
        let removeAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (UIAlertAction) in
            
            FlameBossAPI.removeDevice(deviceID: controller.id, completion: { (error) in
                if error == nil { self.viewModel.refreshDevices() }
                else
                {
                    self.showAlert(title: "Error Removing Controller", message: (error?.localizedDescription)!)
                }
            })
        }
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        removeAlert.addAction(yesAction)
        removeAlert.addAction(noAction)
        
        present(removeAlert, animated: true, completion: nil)
    }
}

extension SmokerControllersViewController : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return viewModel.numberOfSectionsInTable()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return viewModel.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return cellForIndexPath(indexPath)
    }
    
    private func cellForIndexPath(_ indexPath: IndexPath) -> UITableViewCell
    {
        return viewModel.tableCell(tableView: self.tableView, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return viewModel.rowHeight(section: indexPath.section)
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    {
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return viewModel.tableHeaderHeight(section: section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return viewModel.headerView(tableView: tableView, section: section)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return viewModel.footerView()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        headerScrollAdjuster.updateHeaderForScrollView(scrollView)
    }
}
