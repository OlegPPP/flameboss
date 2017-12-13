//
//  HomeViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 2/22/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class HomeViewController: FBViewController
{
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var userCooks = [Cook]()
    fileprivate var localCooks = [Cook]()
    fileprivate var searchingForCooks = false
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var headerDetailLabel: UILabel!
    @IBOutlet weak var searchIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchButton: UIButton!
    
    fileprivate var headerScrollAdjuster: HeaderScrollAdjuster!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        showLoginControllerIfNecessary()
        configure()
    }
    
    private func configure()
    {
        headerScrollAdjuster = HeaderScrollAdjuster(headerImageView: headerImageView,
                               headerHeightConstraint: headerHeightConstraint, headerDetailLabel: headerDetailLabel)
        dismissesKeyboardOnViewTap(true)
        configureTableView()
        
        searchButton.titleLabel?.minimumScaleFactor = 0.5
        searchButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    private func showLoginControllerIfNecessary()
    {
        if UserDataStore.isFirstTimeUsingApp()
        {
            let storyboard = UIStoryboard(name: "Account", bundle: nil)
            present(storyboard.instantiateInitialViewController()!, animated: false, completion: nil)
        }
    }
    
    private func configureTableView()
    {
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = self
        tableView.delegate = self
        let infoCellNib = UINib(nibName: "InfoCell", bundle: nil)
        tableView.register(infoCellNib, forCellReuseIdentifier: "InfoCell")
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        fetchCooks()
        
        tableView.reloadData()
    }
    
    private func fetchCooks()
    {
        self.searchingForCooks = true
        FlameBossAPI.getDevices { (devicesIndex, error) in
            
            guard error == nil else
            {
                print("error getting devices: \(String(describing: error?.localizedDescription))")
                self.searchingForCooks = false
                self.reloadTableOnMainThread()
                return
            }
            
            if let userDevices = devicesIndex?.devices
            {
                self.getMostRecentCooksFromDevices(userDevices, completion: { (cooks) in
                    self.userCooks = cooks
                    self.userCooks.sort {$0.id > $1.id}
                })
            }
            
            if let ipDevices = devicesIndex?.ipDevices
            {
                self.getMostRecentCooksFromDevices(ipDevices, completion: { (cooks) in
                    self.localCooks = cooks
                    self.localCooks.sort {$0.id > $1.id}
                })
            }
            
            self.searchingForCooks = false
            self.reloadTableOnMainThread()
        }
    }
    
    fileprivate func getMostRecentCooksFromDevices(_ devices: [Device], completion: @escaping ([Cook]) -> Void)
    {
        var cooks = [Cook]()
        
        for device in devices
        {
            if let mostRecentCook = device.mostRecentCook
            { cooks.append(mostRecentCook) }
        }
        
        completion(cooks)
    }
    
    fileprivate func fetchDataForCook(cookID: Int, completion: @escaping (Cook?) -> Void)
    {
        FlameBossAPI.getCook(cookID: cookID) { (cook, error) in
            guard error == nil else
            {
                completion(nil)
                return
            }
            
            completion(cook)
        }
    }
    
    private func reloadTableOnMainThread()
    {
        DispatchQueue.main.async
            { self.tableView.reloadData() }
    }
    
    private func printDevicesFromRealm()
    {
        let devices = UserDataStore.getDevices()
        for device in devices
        {
            print("device: \(device)")
            print("device cook notices: \(String(describing: device.mostRecentCook?.notices))")
            print("device cook data: \(String(describing: device.mostRecentCook?.data))")
        }
    }
    
    fileprivate func showCookViewController(cook: Cook)
    {
        let cookController = storyboard?.instantiateViewController(withIdentifier: "CookViewController") as! CookViewController
        cookController.cook = cook
        
        navigationController?.pushViewController(cookController, animated: true)
    }
    
    @IBAction func searchButtonTapped()
    {
        showAlertToSearchForCook()
    }
    
    func showAlertToSearchForCook()
    {
        let message = "To view a cook on another controller enter its Device ID"
        let searchAlert = UIAlertController(title: message, message: "", preferredStyle: .alert)
        
        searchAlert.addTextField(configurationHandler: nil)
        
        searchAlert.textFields?[0].placeholder = "Device ID"
        searchAlert.textFields?[0].autocapitalizationType = .words
        searchAlert.textFields?[0].keyboardType = .numberPad
        
        let search = UIAlertAction(title: "View Cook", style: .default)
        { (UIAlertAction) in
            
            let enteredName = searchAlert.textFields?[0].text
            if (enteredName?.characters.count)! > 0
            {
                guard let deviceID = Int(enteredName!) else
                {
                    let message = "Make sure the device ID you entered contains only positive numbers."
                    self.showAlert(title: "Invalid Device ID",  message: message)
                    return
                }
                
                self.findMostRecentCookForDevice(deviceID: deviceID)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        searchAlert.addAction(search)
        searchAlert.addAction(cancel)
        present(searchAlert, animated: true, completion: nil)
    }
    
    private func showAlert(title: String, message: String)
    {
        let errorAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        errorAlert.addAction(okAction)
        
        present(errorAlert, animated: true, completion: nil)
    }

    private func findMostRecentCookForDevice(deviceID: Int)
    {
        searchIndicator.startAnimating()
        searchButton.isUserInteractionEnabled = false
        
        FlameBossAPI.getDevice(deviceID: deviceID) { (device, error) in
            
            guard error == nil else
            {
                DispatchQueue.main.async
                {
                    self.showAlert(title: "Error", message: (error?.localizedDescription)!)
                    print("localized description: \(error!.localizedDescription)")
                    print("\ndebug description: \(error.debugDescription)")
                    self.searchIndicator.stopAnimating()
                    self.searchButton.isUserInteractionEnabled = true
                }
                return
            }
            
            if let cook = device?.mostRecentCook
            {
                self.fetchDataForCook(cookID: cook.id, completion: { (cookWithData) in
                    if cookWithData != nil
                    {
                        DispatchQueue.main.async
                        {
                            self.showCookViewController(cook: cookWithData!)
                            self.searchIndicator.stopAnimating()
                            self.searchButton.isUserInteractionEnabled = true
                        }
                    }
                })
            }
            else
            {
                var deviceName : String
                if((device?.name ?? "").isEmpty){
                    deviceName = "Controller \(device!.id)"
                }
                else{
                    deviceName = device!.name!
                }
                let message = String.init(format: "No recent cooks found for %@", deviceName)
                
                DispatchQueue.main.async
                {
                    self.showAlert(title: "No Recent Cooks", message: message)
                    self.searchIndicator.stopAnimating()
                    self.searchButton.isUserInteractionEnabled = true
                }
            }
        }
    }
}

extension HomeViewController : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return tableHeaderHeight(section: section)
    }
    
    func tableHeaderHeight(section: Int) -> CGFloat
    {
        var height = CGFloat(30)
        if section == 0 { height += 20 }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 75
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let height = tableHeaderHeight(section: section)
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: height))
        headerView.backgroundColor = UIColor.white
        
        let startX = CGFloat(12)
        let startY:CGFloat = (section == 0) ? 20 : 0
        let frame = CGRect(x: startX, y: startY, width: tableView.frame.width - startX, height: 30)
        let headerLabel = UILabel(frame: frame)
        headerView.addSubview(headerLabel)
        
        let font = UIFont.boldSystemFont(ofSize: 23)
        headerLabel.font = font
        headerLabel.textColor = UIColor.black
        
        if section == 0 { headerLabel.text = "Added Controllers" }
        else if section == 1 { headerLabel.text = "Local Controllers" }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        // Removes footer at the bottom of each section so 
        // that the scroll animation smoothly animates
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor =  UIColor.white
        
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var rows = 1
        
        if section == 0 && userCooks.count > 0
        { rows = userCooks.count }
            
        else if section == 1 && localCooks.count > 0
        { rows = localCooks.count }
        
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.section == 0 { return cellForUserCooksSection(indexPath: indexPath) }
            
        else if indexPath.section == 1 { return cellForLocalCooksSection(indexPath: indexPath) }
        
        return UITableViewCell()
    }
    
    private func cellForUserCooksSection(indexPath: IndexPath) -> UITableViewCell
    {
        if userCooks.count > 0 { return cookCellForCook(userCooks[indexPath.row]) }
        
        return getInfoCell(searchingTitle: "Searching for recent cooks",
                        notSearchingTitle: "No recent cooks found")
    }
    
    private func cellForLocalCooksSection(indexPath: IndexPath) -> UITableViewCell
    {
        if localCooks.count > 0 { return cookCellForCook(localCooks[indexPath.row]) }
        
        return getInfoCell(searchingTitle: "Searching for recent cooks",
                        notSearchingTitle: "No recent cooks found")
    }
    
    private func cookCellForCook(_ cook: Cook) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CookTableCell") as! CookTableCell
        cell.configureWithCook(cook)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private func getInfoCell(searchingTitle: String, notSearchingTitle: String) -> UITableViewCell
    {
        var text = searchingTitle
        var isSearching = true
        
        if !searchingForCooks
        {
            text = notSearchingTitle
            isSearching = false
        }
        
        let infoCell = tableView.dequeueReusableCell(withIdentifier: "InfoCell") as! InfoCell
        infoCell.configure(text: text, showLoadingIndicator: isSearching, showBorder: false)
        
        return infoCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0
        {
            let cook = userCooks[indexPath.row]
            showCookViewController(cook: cook)
        }
        
        else if indexPath.section == 1
        {
            let cook = localCooks[indexPath.row]
            showCookViewController(cook: cook)
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    {
        if indexPath.section == 0 && indexPath.row < userCooks.count { return true}
        if indexPath.section == 1 && indexPath.row < localCooks.count { return true}
        
        return false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        headerScrollAdjuster.updateHeaderForScrollView(scrollView)
    }
}
