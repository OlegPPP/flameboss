//
//  ConfigureSoundViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 4/13/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class ConfigureSoundViewController : FBViewController
{
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var soundSegmentedControl: UISegmentedControl!
    
    public var smokerController: Device?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        statusBarStyle = .default
        setHeaderLabelText()
        
        guard let device = smokerController else { return }
        soundSegmentedControl.selectedSegmentIndex = device.getSoundSetting().rawValue
    }
    
    private func setHeaderLabelText()
    {
        if let device = smokerController
        {
            headerLabel.text = "Sound Settings for \(device.getName())"
        } 
    }
    
    @IBAction func setSound()
    {
        guard let device = smokerController else { return }
        let index = soundSegmentedControl.selectedSegmentIndex
        let soundSetting = DeviceSoundSetting(rawValue: index)!
        
        FlameBossAPI.setDeviceSound(deviceID: device.id, soundSetting: soundSetting) { (error) in
            
            DispatchQueue.main.async
            {
                if error == nil { self.showSoundSetAlert() }
                        
                else { self.showErrorAlert(erorMessage: (error?.localizedDescription)!) }
            }
        }
    }
    
    private func showSoundSetAlert()
    {
        let message = "New sound settings has been sent to your controller"
        let controllerAddedAlert = UIAlertController(title: "Sound Settings Sent", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (alertAction) in
            super.back()
        }
        
        controllerAddedAlert.addAction(okAction)
        
        present(controllerAddedAlert, animated: true, completion: nil)
    }
    
    private func showErrorAlert(erorMessage: String)
    {
        let errorAlert = UIAlertController(title: "Error Setting Sound", message: erorMessage, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        errorAlert.addAction(okAction)
        
        present(errorAlert, animated: true, completion: nil)
    }
}

public enum DeviceSoundSetting : Int
{
    case Silent = 0
    case ChirpsOnly = 1
    case ChirpsAndAlarms = 2
}













