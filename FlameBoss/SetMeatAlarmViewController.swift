//
//  SetMeatAlarmViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 6/1/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class SetMeatAlarmViewController : FBViewController
{
    private var tempScale: TempScale = .Fahrenheit
    private var device: Device?
    private var meatIndex: Int = 0 // FlameBoss 300 can support up to 3 meats
    private var tempSymbol: String { return tempScale == .Fahrenheit ? "°F" : "°C" }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var meatAlarmTempTextField: UITextField!
    @IBOutlet weak var warmTempTextField: UITextField!
    @IBOutlet weak var notifySwitch: UISwitch!
    @IBOutlet weak var keepWarmSwitch: UISwitch!
    @IBOutlet weak var rangeLabel: UILabel!
    @IBOutlet weak var setButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        titleLabel.text = "Meat \(meatIndex + 1) Alarm"
        statusBarStyle = .default
        dismissesKeyboardOnViewTap(true)
        notifySwitch.onTintColor = UIColor.createColor(red: 105, green: 188, blue: 41, alpha: 1.0)
        keepWarmSwitch.onTintColor = UIColor.createColor(red: 105, green: 188, blue: 41, alpha: 1.0)
        configureView()
    }
    
    public func setDevice(_ device: Device?, tempScale: TempScale, andMeatIndex meatIndex: Int)
    {
        self.device = device
        self.tempScale = tempScale
        self.meatIndex = meatIndex
    }
    
    @IBAction func set()
    {
        setMeatAlarm()
    }
    
    private func configureView()
    {
        guard let device = device else { return }
        
        meatAlarmTempTextField.placeholder = "Enter Meat Done Temp (\(tempSymbol))"
        if let meatAlarmTemps = device.meatAlarmTempsTdc()
        {
            let tdcValue = meatAlarmTemps[meatIndex]
            let tempValue = (tempScale == .Fahrenheit) ? tdcValue.tdcToFahrenheit : tdcValue.tdcToCelsius
            meatAlarmTempTextField.text = "\(tempValue)"
        }
        
        warmTempTextField.placeholder = "Enter Warm Temp (\(tempSymbol))"
        if let warmTempTdc = device.meatAlarmWarmTempTdc()
        {
            let tempValue = (tempScale == .Fahrenheit) ? warmTempTdc.tdcToFahrenheit : warmTempTdc.tdcToCelsius
            warmTempTextField.text = "\(tempValue)"
        }
        
        configureSwitches()
        
        let range = getTempRange()
        rangeLabel.text = "values must be between \(range.lowest) to \(range.highest)"
    }
    
    private func configureSwitches()
    {
        guard let device = device else { return }
        
        if let meatAlarmActions = device.meatAlarmActions()
        {
            let meatAction = meatAlarmActions[meatIndex]
            if meatAction == 0
            {
                notifySwitch.isOn = false
                keepWarmSwitch.isOn = false
            }
            else if meatAction == 1
            {
                notifySwitch.isOn = true
                keepWarmSwitch.isOn = false
            }
            else
            {
                notifySwitch.isOn = true
                keepWarmSwitch.isOn = true
            }
        }
    }
    
    private func getTempRange() -> (lowest: String, highest: String)
    {
        var lowest = device!.minSetTempTdc.tdcToFahrenheit
        var highest = device!.maxSetTempTdc.tdcToFahrenheit
        
        if tempScale == .Celsius
        {
            lowest = lowest.fahrenheitToCelsius
            highest = highest.fahrenheitToCelsius
        }
        
        return ("\(lowest) \(tempSymbol)", "\(highest) \(tempSymbol)")
    }
    
    private func isValueWithinRange(value: Int) -> Bool
    {
        return (value >= device!.minSetTempTdc && value <= device!.maxSetTempTdc)
    }
    
    private func setMeatAlarm()
    {
        hideSetButtonAndStartAnimating()
        
        let meatAlarmErrorTitle = "Error Setting Meat Alarm"
        guard let device = device else
        {
            showErrorAlert(title: meatAlarmErrorTitle, message: ErrorMessage.noDevice())
            showSetButtonAndStopAnimating()
            return
        }
        
        guard let meatTempValue = Int(meatAlarmTempTextField.text!) else
        {
            showErrorAlert(title: meatAlarmErrorTitle, message: ErrorMessage.invalidNotifyNumber())
            showSetButtonAndStopAnimating()
            return
        }
        
        guard let warmTempValue = Int(warmTempTextField.text!) else
        {
            showErrorAlert(title: meatAlarmErrorTitle, message: ErrorMessage.invalidKeepWarmNumber())
            showSetButtonAndStopAnimating()
            return
        }
        
        let tdcMeat = (tempScale == .Fahrenheit) ? meatTempValue.fahrenheitToTdc : meatTempValue.celsiusToTdc
        if !isValueWithinRange(value: tdcMeat)
        {
            showErrorAlert(title: meatAlarmErrorTitle, message: ErrorMessage.invalidNotifyRange(range: getTempRange()))
            showSetButtonAndStopAnimating()
            return
        }
        
        let tdcWarm = (tempScale == .Fahrenheit) ? warmTempValue.fahrenheitToTdc : warmTempValue.celsiusToTdc
        
        if !isValueWithinRange(value: tdcWarm)
        {
            showErrorAlert(title: meatAlarmErrorTitle, message: ErrorMessage.invalidKeepWarmRange(range: getTempRange()))
            showSetButtonAndStopAnimating()
            return
        }
        
        var mode = (notifySwitch.isOn) ? 1 : 0
        if keepWarmSwitch.isOn { mode = 2 }
        
        FlameBossAPI.setDeviceMeatAlarm(deviceID: device.id, index: meatIndex, mode: mode, tdcTemperature: tdcMeat,
                                        tdcWarmTemperature: tdcWarm) { (error) in
            DispatchQueue.main.async
            {
                self.showSetButtonAndStopAnimating()
                
                if error == nil
                {
                    self.showSuccessAlert()
                    print("Meat alarm successfully changed")
                }
                else
                {
                    self.showErrorAlert(title: meatAlarmErrorTitle, message: (error?.localizedDescription)!)
                }
            }
        }
    }
    
    private func showSetButtonAndStopAnimating()
    {
        self.activityIndicator.stopAnimating()
        self.setButton.isEnabled = true
        self.setButton.isHidden = false
    }
    
    private func hideSetButtonAndStartAnimating()
    {
        self.activityIndicator.startAnimating()
        self.setButton.isEnabled = false
        self.setButton.isHidden = true
    }
    
    private func showErrorAlert(title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func showSuccessAlert()
    {
        let alert = UIAlertController(title: "Meat Alarm Successfully Updated", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

private struct ErrorMessage
{
    static func noDevice() -> String
    {
        return "Could not communicate with the smoker controller assocaited with this cook. Make sure the device is still online"
    }
    
    static func invalidNotifyNumber() -> String
    {
        return "The notify value you entered is not a valid number. Please enter a valid number"
    }
    
    static func invalidKeepWarmNumber() -> String
    {
        return "The keep warm value you entered is not a valid number. Please enter a valid number"
    }
    
    static func invalidNotifyRange(range: (lowest: String, highest: String)) -> String
    {
        return "The notify number you entered is not within range. Please enter a value between \(range.lowest) and \(range.highest)"
    }
    
    static func invalidKeepWarmRange(range: (lowest: String, highest: String)) -> String
    {
        return "The keep warm number you entered is not within range. Please enter a value between \(range.lowest) and \(range.highest)"
    }
}

