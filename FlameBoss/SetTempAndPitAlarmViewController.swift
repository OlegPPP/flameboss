//
//  SetTempAndPitAlarmViewController.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 5/31/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import UIKit

class SetTempAndPitAlarmViewController : FBViewController
{
    private var tempScale: TempScale = .Fahrenheit
    private var device: Device?
    private var setTemp: Int?
    private var tempSymbol: String { return tempScale == .Fahrenheit ? "°F" : "°C" }
    
    @IBOutlet weak var setTempTextField: UITextField!
    @IBOutlet weak var diffLimitTextField: UITextField!
    @IBOutlet weak var diffLimitSwitch: UISwitch!
    @IBOutlet weak var setTempRangeLabel: UILabel!
    @IBOutlet weak var pitAlarmRangeLabel: UILabel!
    @IBOutlet weak var setButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        statusBarStyle = .default
        dismissesKeyboardOnViewTap(true)
        diffLimitSwitch.onTintColor = UIColor.createColor(red: 105, green: 188, blue: 41, alpha: 1.0)
        configureView()
    }
    
    public func setDevice(_ device: Device?, currentSetTemp: Int, andTempScale tempScale: TempScale)
    {
        self.device = device
        self.setTemp = currentSetTemp
        self.tempScale = tempScale
    }
    
    private func configureView()
    {
        guard device != nil && setTemp != nil else { return }
        
        setTempTextField.placeholder = "Enter Set Temp (\(tempSymbol))"
        if let temp = setTemp { setTempTextField.text = "\(temp)" }
            
        diffLimitTextField.placeholder = "Enter Difference Limit (\(tempSymbol))"
        if let pitAlarmRange = device!.pitAlarmRangeTdc()
        {
            let tempValue = tdcToUserScaleDiff(value: pitAlarmRange)
            diffLimitTextField.text = "\(tempValue)"
        }
        diffLimitSwitch.isOn = device!.isPitAlarmEnabled()
        
        var range = getTempRange()
        setTempRangeLabel.text = "value must be between \(range.lowest) to \(range.highest)"
        
        range = getDiffLimitRange()
        pitAlarmRangeLabel.text = "value must be between \(range.lowest) to \(range.highest)"
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
    
    private func getDiffLimitRange() -> (lowest: String, highest: String)
    {
        var range = device!.diffLimitTdcRange()
        range.lowest = tdcToUserScaleDiff(value: range.lowest)
        range.highest = tdcToUserScaleDiff(value: range.highest)
        
        return ("\(range.lowest) \(tempSymbol)", "\(range.highest) \(tempSymbol)")
    }
    
    private func isValueWithinPitTempRange(tdcValue: Int) -> Bool
    {
        return (tdcValue >= device!.minSetTempTdc && tdcValue <= device!.maxSetTempTdc)
    }
    
    private func isValueWithinDiffLimitRange(value: Int) -> Bool
    {
        let range = device!.diffLimitTdcRange()
        return (value >= range.lowest && value <= range.highest)
    }
    
    @IBAction func set()
    {
        setTempAndPitAlarm()
    }
    
    private func setTempAndPitAlarm()
    {
        setPitTemp()
    }
    
    private func setPitTemp()
    {
        hideSetButtonAndStartAnimating()
        
        let tempAlertErrorTitle = "Error Setting Set Temp"
        guard let device = device else
        {
            showErrorAlert(title: tempAlertErrorTitle, message: ErrorMessage.noDevice())
            showSetButtonAndStopAnimating()
            return
        }
        
        let enteredText = setTempTextField.text!
        guard let tempValue = Int(enteredText) else
        {
            showErrorAlert(title: tempAlertErrorTitle, message: ErrorMessage.invalidNumber())
            showSetButtonAndStopAnimating()
            return
        }
        
        let tdcValue = (tempScale == .Fahrenheit) ? tempValue.fahrenheitToTdc : tempValue.celsiusToTdc
        guard isValueWithinPitTempRange(tdcValue: tdcValue) else
        {
            showErrorAlert(title: tempAlertErrorTitle, message: ErrorMessage.invalidRange(range: getTempRange()))
            showSetButtonAndStopAnimating()
            return
        }
        
        FlameBossAPI.setDeviceTemperature(deviceID: device.id, tdcTemperature: tdcValue, completion: { (error) in
            DispatchQueue.main.async
            {
                self.showSetButtonAndStopAnimating()
                if error == nil
                {
                    self.setPitAlarm()
                    print("Set temp successfully changed")
                }
                else
                {
                    self.showErrorAlert(title: tempAlertErrorTitle, message: error.debugDescription)
                    print("Could not change set temp")
                }
            }
        })
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
    
    private func setPitAlarm()
    {
        hideSetButtonAndStartAnimating()
        
        let pitAlertErrorTitle = "Error Setting Pit Alarm"
        guard let device = device else
        {
            showErrorAlert(title: pitAlertErrorTitle, message: ErrorMessage.noDevice())
            showSetButtonAndStopAnimating()
            return
        }
        
        let enteredText = diffLimitTextField.text!
        guard var rangeValue = Int(enteredText) else
        {
            showErrorAlert(title: pitAlertErrorTitle, message: ErrorMessage.invalidNumber())
            showSetButtonAndStopAnimating()
            return
        }
        
        let enabled = (diffLimitSwitch.isOn) ? 1 : 0
        rangeValue = userScaleDiffToTdc(value: rangeValue)
        guard isValueWithinDiffLimitRange(value: rangeValue) else
        {
            showErrorAlert(title: pitAlertErrorTitle, message: ErrorMessage.invalidRange(range: getDiffLimitRange()))
            showSetButtonAndStopAnimating()
            return
        }
        
        FlameBossAPI.setDevicePitTempAlarm(deviceID: device.id, enabled: enabled, tdcRange: rangeValue) { (error) in
            DispatchQueue.main.async
            {
                self.showSetButtonAndStopAnimating()
                
                if error == nil
                {
                    self.showSuccessAlert()
                    print("Pit temp alarm successfully changed")
                }
                else
                {
                    self.showErrorAlert(title: pitAlertErrorTitle, message: (error?.localizedDescription)!)
                    print("Could not change pit temp alarm")
                }
            }
        }
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
        let alert = UIAlertController(title: "Set Temp & Pit Alarm Successfully Updated", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func tdcToUserScaleDiff(value: Int) -> Int
    {
        let celsiusValue = Double(value) / 10.0
        if tempScale == .Celsius { return Int(round(celsiusValue)) }
        return Int(round(celsiusValue * 9.0/5.0))
    }
    
    private func userScaleDiffToTdc(value: Int) -> Int
    {
        let celsiusValue = Double(value) * 10.0
        if tempScale == .Celsius { return Int(round(celsiusValue)) }
        return Int(round(celsiusValue * 5.0/9.0))
    }
}

private struct ErrorMessage
{
    static func noDevice() -> String
    {
        return "Could not communicate with the smoker controller assocaited with this cook. Make sure the device is still online"
    }
    static func invalidNumber() -> String
    {
        return "The value you entered is not a valid number. Please enter a valid number"
    }
    
    static func invalidRange(range: (lowest: String, highest: String)) -> String
    {
        return "The number you entered is not within range. Please enter a value between \(range.lowest) and \(range.highest)"
    }
}
