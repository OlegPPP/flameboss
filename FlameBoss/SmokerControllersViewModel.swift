//
//  SmokerControllersViewModel.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 4/19/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation
import UIKit

class SmokerControllersViewModel : NSObject
{
    fileprivate var addedDevices = [Device]()
    fileprivate var localDevices = [Device]()
    fileprivate var searchingForDevices = false
    
    public var updateAppearanceCallback: (() -> ())!
    public var editNameCallback: ((Device) -> ())!
    public var editWifiCallback: ((Device) -> ())!
    public var editSoundCallback: ((Device) -> ())!
    public var removeDeviceCallback: ((Device) -> ())!
    public var addDeviceCallback: ((Device) -> ())!
    
    init(updateAppearanceCallback: @escaping () -> ())
    {
        super.init()
        
        self.updateAppearanceCallback = updateAppearanceCallback
        fetchDevicesFromApi()
    }
    
    public func refreshDevices()
    {
        fetchDevicesFromApi()
    }
    
    private func fetchDevicesFromApi()
    {
        if searchingForDevices { return }
        
        searchingForDevices = true
        FlameBossAPI.getDevices { (devicesIndex, error) in
            
            guard error == nil else
            {
                print("error getting devices: \(String(describing: error?.localizedDescription))")
                self.searchingForDevices = false
                self.updateAppearanceCallback()
                return
            }
            
            if let userDevices = devicesIndex?.devices
            { self.addedDevices = userDevices }
            
            if let ipDevices = devicesIndex?.ipDevices
            { self.localDevices = ipDevices }
            
            self.searchingForDevices = false
            
            self.updateAppearanceCallback()
        }
    }
    
    public func numberOfSectionsInTable() -> Int { return 2 }
    
    func tableHeaderHeight(section: Int) -> CGFloat
    {
        var height = CGFloat(30)
        if section == 0 { height += 20 }
        
        return height
    }
    
    public func rowHeight(section: Int) -> CGFloat
    {
        if section == 0 && addedDevices.count <= 0 { return 75 }
        else if section == 1 && localDevices.count <= 0 { return 75 }
        
        return 130
    }
    
    public func numberOfRowsInSection(_ section: Int) -> Int
    {
        var rows = 1
        
        if section == 0 && addedDevices.count > 0
        { rows = addedDevices.count }
            
        else if section == 1 && localDevices.count > 0
        { rows = localDevices.count }
        
        return rows
    }
    
    
    public func headerView(tableView: UITableView, section: Int) -> UIView
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
    
    public func footerView() -> UIView
    {
        // Removes footer at the bottom of each section so
        // that the scroll animation smoothly animated
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor =  UIColor.white
        
        return view
    }
    
    public func tableCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
    {
        var cell = UITableViewCell()
        
        if indexPath.section == 0
        { cell = cellForUserDevicesSection(tableView: tableView, indexPath: indexPath) }
            
        else if indexPath.section == 1
        { cell = cellForIpDevicesSection(tableView: tableView, indexPath: indexPath) }
        
        return cell
    }
    
    private func cellForUserDevicesSection(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
    {
        if addedDevices.count == 0
        {
            let infoCell = getInfoCell(tableView: tableView, searchingTitle: "Searching for your added controllers",
                                       notSearchingTitle: "No added controllers found")
            
            return infoCell
        }
        
        let deviceCell = tableView.dequeueReusableCell(withIdentifier: "MyDeviceCell") as! MyDeviceCell
        deviceCell.addTagForButtons(indexPath.row)
        addButtonEventsForDeviceCell(deviceCell)
        
        let device = addedDevices[indexPath.row]
        deviceCell.configureWithDevice(device)
        
        return deviceCell
    }
    
    private func cellForIpDevicesSection(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
    {
        if localDevices.count == 0
        {
            let infoCell = getInfoCell(tableView: tableView, searchingTitle: "Searching for local controllers",
                                       notSearchingTitle: "No local controllers found")
            
            return infoCell
        }
        
        let deviceCell = tableView.dequeueReusableCell(withIdentifier: "AddDeviceCell") as! AddDeviceCell
        
        let device = localDevices[indexPath.row]
        deviceCell.configureWithDevice(device, added: isDeviceAdded(device))
        
        deviceCell.addDeviceButton.tag = indexPath.row
        deviceCell.addDeviceButton.addTarget(self, action: #selector(addDevice), for: .touchUpInside)
        
        return deviceCell
    }
    
    private func addButtonEventsForDeviceCell(_ deviceCell: MyDeviceCell)
    {
        deviceCell.editNameButton.addTarget(self, action: #selector(editName), for: .touchUpInside)
        deviceCell.wifiButton.addTarget(self, action: #selector(editWifi), for: .touchUpInside)
        deviceCell.soundButton.addTarget(self, action: #selector(editSound(_:)), for: .touchUpInside)
        deviceCell.removeButton.addTarget(self, action: #selector(removeDevice), for: .touchUpInside)
    }
    
    func editName(_ button: UIButton) { editNameCallback(addedDevices[button.tag]) }
    
    func editWifi(_ button: UIButton) { editWifiCallback(addedDevices[button.tag]) }
    
    func editSound(_ button: UIButton) { editSoundCallback(addedDevices[button.tag]) }
    
    func removeDevice(_ button: UIButton) { removeDeviceCallback(addedDevices[button.tag]) }
    
    func addDevice(_ button: UIButton) { addDeviceCallback(localDevices[button.tag]) }
    
    private func isDeviceAdded(_ device: Device) -> Bool
    {
        for userDevice in addedDevices
        {
            if device.id == userDevice.id { return true }
        }
        
        return false
    }
    
    private func getInfoCell(tableView: UITableView, searchingTitle: String, notSearchingTitle: String) -> UITableViewCell
    {
        var text = searchingTitle
        var searching = true
        
        if !searchingForDevices
        {
            text = notSearchingTitle
            searching = false
        }
        
        let infoCell = tableView.dequeueReusableCell(withIdentifier: "InfoCell") as! InfoCell
        infoCell.configure(text: text, showLoadingIndicator: searching, showBorder: false)
        
        return infoCell
    }
    
    public func isUserLoggedIn() -> Bool { return UserDataStore.isUserLoggedIn() }
}
