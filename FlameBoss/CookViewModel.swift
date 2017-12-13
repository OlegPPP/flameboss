//
//  CookViewModel.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 3/24/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation
import UIKit

class CookViewModel : NSObject
{
    public var cook: Cook!
    public var timeLabelFrame = CGRect.zero
    public var graphFrame = CGRect.zero
    public var updateAppearanceCallback: (() -> ())!
    
    private var setTempData = [Float]()
    private var pitTempData = [Float]()
    private var blowerOutputData = [Float]()
    
    private var meatTemp1Data = [Float]()
    private var meatTemp2Data = [Float]()
    private var meatTemp3Data = [Float]()
    
    private var isFetchingCookData = false
    private var isUpdatingCookData = false
    private var userOwnsCook = false
    
    private var cookDevice: Device?
    private var railsWebSocket: WsRails?
    private var tempSymbol: String
    {
        return (tempScale() == .Fahrenheit) ? "°F" : "°C"
    }

    private var closeObserver : NSObjectProtocol?
    
    init(cook: Cook, updateAppearanceCallback: @escaping () -> ())
    {
        super.init()
        
        self.cook = cook
        self.updateAppearanceCallback = updateAppearanceCallback
        self.userOwnsCook = FlameBossAPI.deviceIsOwned(deviceID: cook.deviceID)
        
        fetchAllDataForCook()
        addObserverForNotifications()
    }

    public func closeWebSocket()
    {
        if railsWebSocket != nil
        {
            let notificationCenter = NotificationCenter.default
            if closeObserver != nil { notificationCenter.removeObserver(closeObserver!) }
            railsWebSocket?.closeWebSocket()
            railsWebSocket = nil
        }
    }
    
    private func addObserverForNotifications()
    {
        let notificationCenter = NotificationCenter.default
        closeObserver = notificationCenter.addObserver(forName: Notification.Name(rawValue: "WebSocketClosed"), object: nil, queue: nil) { (Notification) in
            self.startWebSocket()
        }
        
        notificationCenter.addObserver(forName: Notification.Name(rawValue: "AppBecameActive"), object: nil, queue: nil)
        { (Notification) in
            self.fetchUpdatedDataForCook()
        }
    }
    
    private func startWebSocket()
    {
        if railsWebSocket == nil
        {
            railsWebSocket = FlameBossAPI.wsRails()
        }
        else
        {
            railsWebSocket?.openWebSocket()
            railsWebSocket?.unsubscribe(channelName: "\(self.cook.id)")
        }
        
        railsWebSocket?.bind(eventName: "client_connected") { (event_name, data) in
            
            let channel = self.railsWebSocket?.subscribe(channelName: "\(self.cook.id)")
            
            channel?.bind(eventName: "cook_data") { (event_name, data) in
                if let cookDatum = CookData(json: data)
                {
                    self.cook.online = true
                    self.updateCookWithNewData(newData: [cookDatum])
                }
            }
            
            channel?.bind(eventName: "offline") { (event_name, data) in
                self.cook.online = false
                if self.updateAppearanceCallback != nil { self.updateAppearanceCallback() }
            }
        }
    }
    
    public func refreshDataForCook() {
        fetchUpdatedDataForCook()
    }
    
    private func fetchUpdatedDataForCook()
    {
        if isFetchingCookData { return }
        
        self.isFetchingCookData = true
        FlameBossAPI.getCook(cookID: cook.id, skipCount: cook.dataCount) { (cook, error) in
            
            if let cookWithNewData = cook
            {
                self.updateCookWithNewData(newData: Array(cookWithNewData.data))
            }
            
            self.isFetchingCookData = false
        }
    }
    
    private func updateCookWithNewData(newData: [CookData])
    {
        if isUpdatingCookData { return }
        
        self.isUpdatingCookData = true
        let previousDataCount = self.cook.dataCount
        self.cook.data.append(contentsOf: newData)
        self.cook.dataCount = self.cook.data.count
        self.parseDataFromCook(startIndex: previousDataCount)
        if self.updateAppearanceCallback != nil { self.updateAppearanceCallback() }
        self.isUpdatingCookData = false
    }
    
    private func fetchAllDataForCook()
    {
        if isFetchingCookData { return }
        
        self.isFetchingCookData = true
        FlameBossAPI.getCook(cookID: cook.id) { (cook, error) in

            if let cookWithData = cook
            {
                self.cook = cookWithData
                self.parseDataFromCook(startIndex: 0)
            }

            self.isFetchingCookData = false

            if self.updateAppearanceCallback != nil { self.updateAppearanceCallback() }

            self.startWebSocket()
        }
    }
    
    public func refreshDeviceForCook() {
        fetchDeviceForCook()
    }
    
    private func fetchDeviceForCook()
    {
        FlameBossAPI.getDevice(deviceID: cook.deviceID) { (device, error) in
            if error == nil { self.cookDevice = device; self.setIfUserOwnsCook() }
            else
            {
                print("Error getting device for cook: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    private func setIfUserOwnsCook()
    {
        FlameBossAPI.getDevices { (devicesIndex, error) in
            
            guard error == nil else { return }
            
            if let userDevices = devicesIndex?.devices
            {
                guard self.cookDevice != nil else { return }
                
                for device in userDevices
                {
                    if device.id == self.cookDevice?.id { self.userOwnsCook = true; return }
                }
            }
            self.userOwnsCook = false
        }
    }
    
    private func parseDataFromCook(startIndex: Int)
    {
        guard startIndex < cook.data.count else { return }
        
        if startIndex == 0 { clearDataArrays() }
        
        for i in startIndex ..< cook.data.count
        {
            let data = cook.data[i]
            parseDataFromCookDatum(data)
        }
    }

    private func parseDataFromCookDatum(_ data : CookData)
    {
        var value = data.setTemperature
        let set = (tempScale() == .Celsius) ? value.tdcToCelsius : value.tdcToFahrenheit
        setTempData.append(Float(set))

        value = data.pitTemperature
        let pit = (tempScale() == .Celsius) ? value.tdcToCelsius : value.tdcToFahrenheit
        pitTempData.append(Float(pit))

        let blower = round(Float(data.fanDc)/Float(100))
        blowerOutputData.append(blower)

        value = data.meatTemperatures[0].intValue
        var meatTemp = (tempScale() == .Celsius) ? value.tdcToCelsius : value.tdcToFahrenheit
        meatTemp1Data.append(Float(meatTemp))

        value = data.meatTemperatures[1].intValue
        meatTemp = (tempScale() == .Celsius) ? value.tdcToCelsius : value.tdcToFahrenheit
        meatTemp2Data.append(Float(meatTemp))

        value = data.meatTemperatures[2].intValue
        meatTemp = (tempScale() == .Celsius) ? value.tdcToCelsius : value.tdcToFahrenheit
        meatTemp3Data.append(Float(meatTemp))
    }
    
    private func clearDataArrays()
    {
        setTempData = [Float]()
        pitTempData = [Float]()
        blowerOutputData = [Float]()
        
        meatTemp1Data = [Float]()
        meatTemp2Data = [Float]()
        meatTemp3Data = [Float]()
    }
    
    public func tempScale() -> TempScale
    {
        if let user = FlameBossAPI.getUser() { return user.tempScale }
        
        return NSLocale.current.usesMetricSystem ? .Celsius : .Fahrenheit
    }
    
    private func formattedDateFromDateString(_ dateString: String?) -> String?
    {
        if dateString == nil { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from:dateString!)
        {
            dateFormatter.dateFormat = "MMM dd  EEE   h:mma   yyyy"
            return dateFormatter.string(from: date).uppercased()
        }
        
        return nil
    }
    
    public func canEditAlarmAndTemperatures() -> Bool
    {
        return isCookActive() && userOwnsCook
    }
    
    public func canEditTitleOrNotes() -> Bool
    {
        return userOwnsCook
    }
    
    private func isCookActive() -> Bool
    {
        guard let device = cookDevice else { return false }
        
        guard let mostRecentCook = device.mostRecentCook else { return false }
        
        if device.online && mostRecentCook.id == cook.id { return true }
        
        return false
    }
    
    public func isMeatTempsValid(_ meatTemps: [Float]) -> Bool
    {
        if meatTemps.count <= 0 { return false }
        return !containsAllZeroes(array: meatTemps)
    }
    
    public func containsAllZeroes(array: [Float]) -> Bool
    {
        for number in array { if number != 0 { return false } }
        
        return true
    }
    
    public func canEditMeat2Temp() -> Bool
    {
        let lastIndex = meatTemp2Data.count - 1
        if lastIndex < 0 { return false }
        
        let temp = Int(meatTemp2Data[lastIndex])
        return (temp > 0 && canEditAlarmAndTemperatures())
    }
    
    public func canEditMeat3Temp() -> Bool
    {
        let lastIndex = meatTemp3Data.count - 1
        if lastIndex < 0 { return false }
        
        let temp = Int(meatTemp3Data[lastIndex])
        return (temp > 0 && canEditAlarmAndTemperatures())
    }
    
    public func graphXAxisLabels() -> [Float]
    {
        let dataCount = Float(cook.data.count)
        return [0, dataCount*0.20, dataCount*0.4, dataCount*0.6, dataCount*0.80]
    }
    
    public func graphXAxisLabelFormatter(index: Int, value: Float) -> String
    {
        let dateIndex = Int(value)
        
        guard dateIndex >= 0 && dateIndex < cook.data.count else { return "" }
        
        let seconds = self.cook.data[dateIndex].sec
        let date = Date.init(timeIntervalSince1970: TimeInterval(seconds))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        return dateFormatter.string(from: date)
    }
    
    public func xPositionForTimeLabel(xAxisValue: CGFloat, xTouchPositonOnGraph: CGFloat) -> Float
    {
        var x = xTouchPositonOnGraph
        if shouldShowTimeOnLeftSide(xTouchPositonOnGraph: xTouchPositonOnGraph)
        {
            x = xTouchPositonOnGraph - timeLabelFrame.width - 10
        }
        
        return Float(x)
    }
    
    public func shouldShowTimeOnLeftSide(xTouchPositonOnGraph: CGFloat) -> Bool
    {
        return (xTouchPositonOnGraph + timeLabelFrame.width) > (graphFrame.origin.x + graphFrame.width)
    }
    
    public func timeForXAxisValue(_ xAxisValue: Int) -> String
    {
        let index = xAxisValue // (xAxisValue < cook.data.count) ? xAxisValue : 0
        
        guard index >= 0 && index < cook.data.count else { return "" }
        
        let date = Date.init(timeIntervalSince1970: TimeInterval(cook.data[index].sec))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        return dateFormatter.string(from: date)
    }
    
    public func getGraphDataValues_ForXAxisValue(_ xAxisValue: Int) -> [String: String]
    {
        let index = xAxisValue
        
        var values: [String: String] = ["set":"---", "pit":"---", "blower":"---", "meat":"---"]
        
        if isIndexInRange(index: index, array: setTempData)
            { values["set"] = "\(Int(setTempData[index])) \(tempSymbol)" }
        
        if isIndexInRange(index: index, array: pitTempData)
            { values["pit"] = "\(Int(pitTempData[index])) \(tempSymbol)" }
        
        if isIndexInRange(index: index, array: blowerOutputData)
            { values["blower"] = "\(Int(blowerOutputData[index]))%" }
        
        if isIndexInRange(index: index, array: meatTemp1Data)
            { values["meat"] = "\(Int(meatTemp1Data[index])) \(tempSymbol)" }
        
        return values
    }
    
    private func isIndexInRange(index: Int, array: [Any]) -> Bool
    {
        return index >= 0 && index < array.count
    }
    
    public func timeFrameForCook() -> String
    {
        var timeframe = ""
        if let cookStartDate = getCookStartDate()
        {
            timeframe = cookStartDate
            
            if let cookEndDate = getCookEndDate()
            {
                timeframe = "\(cookStartDate) - \(cookEndDate)"
            }
        }
        
        return timeframe
    }
    
    public func getCookStartDate() -> String?
    {
        return formattedDateFromDateString(cook.createdAt)
    }
    
    public func getCookEndDate() -> String?
    {
        return formattedDateFromDateString(cook.endedAt)
    }
    
    public func getLastSetTemp() -> String
    {
        let lastIndex = setTempData.count - 1
        if lastIndex < 0 { return "---" }
        
        return String(format: "%d°", Int(setTempData[lastIndex]))
    }
    
    public func getLastSetTempValue() -> Int
    {
        let lastIndex = setTempData.count - 1
        if lastIndex < 0 { return 0 }
        
        return Int(setTempData[lastIndex])
    }
    
    public func getLastPitTemp() -> String
    {
        let lastIndex = pitTempData.count - 1
        if lastIndex < 0 { return "---" }
        
        return String(format: "%d°", Int(pitTempData[lastIndex]))
    }
    
    public func getLastBlowerOutput() -> String
    {
        let lastIndex = blowerOutputData.count - 1
        if lastIndex < 0 { return "---" }
        
        return String(format: "%d%%", Int(blowerOutputData[lastIndex]))
    }
    
    public func getLastMeatTemps() -> [String]
    {
        var meatTemps = [String]()
        
        meatTemps.append(lastMeatTemp(meatTempData: meatTemp1Data))
        meatTemps.append(lastMeatTemp(meatTempData: meatTemp2Data))
        meatTemps.append(lastMeatTemp(meatTempData: meatTemp3Data))
        
        return meatTemps
    }
    
    private func lastMeatTemp(meatTempData: [Float]) -> String
    {
        let lastIndex = meatTempData.count - 1
        if lastIndex < 0 { return "---" }
        
        let temp = Int(meatTempData[lastIndex])
        return (temp > 0) ? "\(temp)°" : "---"
    }
    
    public func updateCook(title: String = "", notes: String = "", keep: Bool = true,
                           completion: @escaping (Error?) -> Void)
    {
        print("notes in update cook: \(notes)")
        FlameBossAPI.updateCook(cookID: cook.id, title: title, notes: notes, keep: keep) { (error) in
            if error == nil
            {
                if !title.isEmpty { self.cook.title = title }
                self.cook.notes = notes
            }
            completion(error)
        }
    }
    
    public func doesCookHaveGraphData() -> Bool
    {
        return (setTempData.count > 0 && pitTempData.count > 0 &&
               blowerOutputData.count > 0 && meatTemp1Data.count > 0)
    }
    
    public func getSetTempData() -> [Float] { return setTempData }
    
    public func getPitTempData() -> [Float] { return pitTempData }
    
    public func getBlowerOutputData() -> [Float] { return blowerOutputData }
    
    public func getMeatTemp1Data() -> [Float] { return meatTemp1Data }
    
    public func getMeatTemp2Data() -> [Float] { return meatTemp2Data }
    
    public func getMeatTemp3Data() -> [Float] { return meatTemp3Data }
    
    public func getCookTitle() -> String? { return cook.title }
    
    public func isControllerOnline() -> Bool { return cook.online }
    
    public func headerText() -> String
    {
        if let title = cook.title { return title }
        else { return "Cook \(cook.id)" }
    }
    
    public func getCookNotes() -> String? { return cook.notes }
    
    public func shareInfoForCook() -> [Any]
    {
        var items = [Any]()
        items.append("Check out my cook with @FlameBossSmokes\n")
        items.append(URL(string: "https://myflameboss.com/cooks/\(cook.id)")!)
        
        return items
    }
    
    public func deviceID() -> Int { return cook.deviceID }
    
    public func getDeviceForCook() -> Device? { return cookDevice }
}
