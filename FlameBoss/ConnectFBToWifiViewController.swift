//
//  ConnectFBToWifiViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 7/20/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class ConnectFBToWifiViewController : FBViewController
{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var connectedView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var lineSeparator: UIView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    public var close: (() -> ())!
    
    public weak var flameBossCommunicator: SmokerDeviceCommunicator?
    
    fileprivate var wifiNetworks = [AccessPoint]()
    fileprivate var selectedWifiNetwork: AccessPoint?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configure()
        loadWifiNetworksAvailable_ToTheDevice()
    }
    
    private func configure()
    {
        showTableView(true, animated: false)
        tableView.dataSource = self
        tableView.delegate = self
        removeEmptyCellsAtBottomOfTable(tableView)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    }
    
    private func loadWifiNetworksAvailable_ToTheDevice()
    {
        guard let flameBossCommunicator = flameBossCommunicator else { return }
        
        flameBossCommunicator.getAccessPointsAvailable { (accessPoints, error) in
            
            if error == nil
            {
                self.wifiNetworks += accessPoints
                self.tableView.reloadData()
                self.tableView.flashScrollIndicators()
                self.loadingIndicator.stopAnimating()
                self.instructionLabel.text = "Select Your Wifi Network"
            }
            else
            {
                print("error while loading wifi networks: \(String(describing: error))")
            }
        }
    }
    
    private func setDeviceWifi(password: String)
    {
        if let wifiNetwork = selectedWifiNetwork
        {
            if let flameBossCommunicator = flameBossCommunicator
            {
                self.instructionLabel.text = "Connecting your FlameBoss to Wifi"
                self.loadingIndicator.startAnimating()
                self.tableView.isUserInteractionEnabled = false
                
                flameBossCommunicator.setWifi(accessPoint: wifiNetwork, key: password, completion: { (error) in
                    self.loadingIndicator.stopAnimating()
                    if error == nil
                    {
                        self.showTableView(false, animated: true)
                        print("smoker controller wifi successfully set")
                    }
                    else
                    {
                        self.instructionLabel.text = "Error connecting your FlameBoss to Wifi. Please try again later"
                        print("error setting controller wifi: \(String(describing: error?.localizedDescription))")
                    }
                })
            }
        }
    }
    
    private func showTableView(_ shouldShowTable: Bool, animated: Bool)
    {
        let alpha:CGFloat = shouldShowTable ? 1 : 0
        let duration = animated ? 1.0 : 0.0
        
        UIView.animate(withDuration: duration, animations:
            {
                self.lineSeparator.alpha = alpha
                self.tableView.alpha = alpha
                self.connectedView.alpha = 1 - alpha
                self.bottomView.alpha = 1 - alpha
        }, completion: { (Bool) in
        })
    }
    
    fileprivate func showAlertToEnterWifiPassword(networkName: String)
    {
        let message = "Enter the password for \(networkName). Please double check to make sure that this is the " +
                      "correct password"
        let textFieldAlert = UIAlertController(title: "Wifi Password", message: message, preferredStyle: .alert)
        
        textFieldAlert.addTextField(configurationHandler: textFieldHandler)

        let okAction = UIAlertAction(title: "Done", style: .default)
        { (UIAlertAction) in
            
            if let enteredPassword = textFieldAlert.textFields?[0].text
            {
                self.setDeviceWifi(password: enteredPassword)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        textFieldAlert.addAction(okAction)
        textFieldAlert.addAction(cancelAction)
        
        present(textFieldAlert, animated: true, completion: nil)
    }
    
    func textFieldHandler(textField: UITextField!)
    {
        if (textField) != nil {
            textField.isSecureTextEntry = true
            textField.placeholder = "Enter Wifi Password"
            textField.returnKeyType = .done
        }
    }
    
    @IBAction func closeButtonPressed()
    {
        if close != nil { close() }
    }
}

extension ConnectFBToWifiViewController : UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return wifiNetworks.count }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 61.5 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        let wifiNetwork = wifiNetworks[indexPath.row]
        
        cell.textLabel?.text = wifiNetwork.ssid
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedWifiNetwork = wifiNetworks[indexPath.row]
        
        if let wifiNetwork = selectedWifiNetwork
        {
            showAlertToEnterWifiPassword(networkName: wifiNetwork.ssid)
        }
    }
}
