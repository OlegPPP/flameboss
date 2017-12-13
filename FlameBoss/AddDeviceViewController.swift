//
//  AddDeviceViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 3/16/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class AddDeviceViewController : FBViewController
{
    @IBOutlet weak var addControllerView: UIView!
    @IBOutlet weak var deviceIdTextField: UITextField!
    @IBOutlet weak var devicePinTextField: UITextField!
    @IBOutlet weak var serialNumberTextField: UITextField!
    public var device: Device?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configure()
    }
    
    private func configure()
    {
        statusBarStyle = .default
        dismissesKeyboardOnViewTap(true)
        
        if let device = device
        {
            deviceIdTextField.text = String(device.id)
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if let device = device
        {
            deviceIdTextField.text = String(device.id)
            devicePinTextField.becomeFirstResponder()
        }
        else
        {
            deviceIdTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func addController()
    {
        guard let deviceID = UInt(deviceIdTextField.text!) else { return }
        guard let pin = UInt(devicePinTextField.text!) else { return }
        
        let serialNumberText = serialNumberTextField.text!
        let snDigitsCount = serialNumberText.characters.count
        var serialNumber = UInt(0)
        
        if snDigitsCount > 0
        {
            if snDigitsCount != 6 && snDigitsCount != 7
            {
                showErrorAlert(erorMessage: "Serial number should be a 6 or 7 digit number.")
                return
            }
            
            guard let sn = UInt(serialNumberText) else
            {
                showErrorAlert(erorMessage: "Serial number should contain only digits.")
                return
            }
            serialNumber = sn
        }
        
        FlameBossAPI.addDevice(deviceID: deviceID, pin: pin, serialNumber: serialNumber) { (error) in
            DispatchQueue.main.async
            {
                if error == nil { self.showControllerAddedAlert() }
                    
                else { self.showErrorAlert(erorMessage: (error?.localizedDescription)!) }
            }
        }
    }
    
    private func addDeviceToDataStore(devicePin: Int)
    {
        if let device = device
        {
            let standAloneDevice = Device(value: device)
            standAloneDevice.pin = devicePin
            UserDataWriter.saveDevice(standAloneDevice)
        }
    }
    
    private func showControllerAddedAlert()
    {
        let message = "The controller has been successfully added to your account"
        let controllerAddedAlert = UIAlertController(title: "Controller Added", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (alertAction) in
            super.back()
        }
        
        controllerAddedAlert.addAction(okAction)
        
        present(controllerAddedAlert, animated: true, completion: nil)
    }
    
    private func showErrorAlert(erorMessage: String)
    {
        let errorAlert = UIAlertController(title: "Error Adding Controller", message: erorMessage, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        errorAlert.addAction(okAction)
        
        present(errorAlert, animated: true, completion: nil)
    }
    
    @IBAction func removeController()
    {
        guard let deviceID = Int(deviceIdTextField.text!) else { return }
        
        FlameBossAPI.removeDevice(deviceID: deviceID) { (error) in
            if error == nil
            { print("controller successfully removed") }
            else
            { print("error removing controller: \(String(describing: error?.localizedDescription))") }
        }
    }
}
