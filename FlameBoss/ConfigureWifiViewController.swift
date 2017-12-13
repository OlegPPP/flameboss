//
//  ConfigureWifiViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 4/13/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class ConfigureWifiViewController : FBViewController
{
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var wifiNameTextField: UITextField!
    @IBOutlet weak var wifiPasswordTextField: UITextField!
    @IBOutlet weak var securityTypeSegmentedControl: UISegmentedControl!
    
    public var smokerController: Device?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        statusBarStyle = .default
        super.dismissesKeyboardOnViewTap(true)
        setHeaderLabelText()
    }
    
    private func setHeaderLabelText()
    {
        if let device = smokerController
        {
            headerLabel.text = "Wifi Network for \(device.getName())"
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        wifiNameTextField.becomeFirstResponder()
    }
    
    @IBAction func setWifi()
    {
        guard let device = smokerController else { return }
        
        if let name = wifiNameTextField.text, let password = wifiPasswordTextField.text
        {
            if name.characters.count <= 0 || password.characters.count <= 0 { return }
            
            let selectedIndex = UInt8(securityTypeSegmentedControl.selectedSegmentIndex)
            let securityType = WifiSecurityType(rawValue: selectedIndex)!
            
            FlameBossAPI.setDeviceWifi(deviceID: device.id, wifiName: name, securityType: securityType, password: password, completion: { (error) in
                
                DispatchQueue.main.async
                {
                    if error == nil { self.showWifiSetAlert() }
                        
                    else { self.showErrorAlert(erorMessage: (error?.localizedDescription)!) }
                }
            })
        }
    }
    
    private func showWifiSetAlert()
    {
        let message = "New wifi settings have been sent to your controller"
        let controllerAddedAlert = UIAlertController(title: "Wifi Settings Sent", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (alertAction) in
            super.back()
        }
        
        controllerAddedAlert.addAction(okAction)
        
        present(controllerAddedAlert, animated: true, completion: nil)
    }
    
    private func showErrorAlert(erorMessage: String)
    {
        let errorAlert = UIAlertController(title: "Error Setting Wifi", message: erorMessage, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        errorAlert.addAction(okAction)
        
        present(errorAlert, animated: true, completion: nil)
    }
}

extension ConfigureWifiViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if textField == wifiNameTextField
        { wifiPasswordTextField.becomeFirstResponder() }
        
        else if textField == wifiPasswordTextField
        {
            view.endEditing(true)
            setWifi()
        }
        
        return true
    }
}
