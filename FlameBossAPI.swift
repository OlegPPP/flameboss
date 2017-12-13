//
//  FlameBossAPI.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 2/22/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation
import Gloss

class FlameBossAPI : NSObject
{
    public static func wsRails() -> WsRails
    {
        return APICommon.wsRails()
    }

    // MARK: User
    public static func getUser() -> User?
    {
        return UserAPI.getUser()
    }
    
    public static func signUpUser(username: String, email: String, password: String,
                                  completion: @escaping (Error?) -> Void)
    {
        UserAPI.signUpUser(username: username, email: email, password: password, completion: completion)
    }
    
    public static func loginUser(username: String, password: String, completion: @escaping (Error?) -> Void)
    {
        UserAPI.loginUser(username: username, password: password, completion: completion)
    }
    
    public static func initializeUser(completion: ((Error?) -> Void)?)
    {
        UserAPI.initializeUser(completion: completion)
    }
    
    public static func updateUser(user: User, completion: @escaping (Error?) -> Void)
    {
        UserAPI.updateUser(user: user, completion: completion)
    }
    
    public static func logoutCurrentUser(completion: @escaping (Error?) -> Void)
    {
        UserAPI.logoutCurrentUser(completion: completion)
    }
    
    public static func sendApnToken(deviceId: UInt, completion: @escaping (Error?) -> Void)
    {
        UserAPI.sendApnToken(deviceId: deviceId, completion: completion)
    }

    public static func setApnToken(_ token : String)
    {
        UserAPI.setApnToken(token)
    }
    
    // MARK: Device
    public static func deviceIsOwned(deviceID: Int) -> Bool {
        return DeviceAPI.deviceIsOwned(deviceID: deviceID)
    }

    public static func getDevices(completion: @escaping (DevicesIndex?, Error?) -> Void)
    {
        DeviceAPI.getDevices(completion: completion)
    }
    
    public static func getDevice(deviceID: Int, completion: @escaping (Device?, Error?) -> Void)
    {
        DeviceAPI.getDevice(deviceID: deviceID, completion: completion)
    }
    
    public static func addDevice(deviceID: UInt, pin: UInt, serialNumber: UInt, completion: @escaping (Error?) -> Void)
    {
        DeviceAPI.addDevice(deviceID: deviceID, pin: pin, serialNumber: serialNumber, completion: completion)
    }
    
    public static func updateDeviceName(deviceID: Int, newName: String, completion: @escaping (Error?) -> Void)
    {
        DeviceAPI.updateDeviceName(deviceID: deviceID, newName: newName, completion: completion)
    }
    
    public static func removeDevice(deviceID: Int, completion: @escaping (Error?) -> Void)
    {
        DeviceAPI.removeDevice(deviceID: deviceID, completion: completion)
    }
    
    public static func setDeviceTemperature(deviceID: Int, tdcTemperature: Int, completion: @escaping (Error?) -> Void)
    {
        DeviceAPI.setDeviceTemperature(deviceID: deviceID, tdcTemperature: tdcTemperature, completion: completion)
    }
    
    public static func setDeviceWifi(deviceID: Int, wifiName: String, securityType: WifiSecurityType,
        password: String, completion: @escaping (Error?) -> Void)
    {
        DeviceAPI.setDeviceWifi(deviceID: deviceID, wifiName: wifiName, securityType: securityType, password: password, completion: completion)
    }
    
    public static func setDeviceSound(deviceID: Int, soundSetting: DeviceSoundSetting,
        completion: @escaping (Error?) -> Void)
    {
        DeviceAPI.setDeviceSound(deviceID: deviceID, soundSetting: soundSetting, completion: completion)
    }
    
    public static func setDevicePitTempAlarm(deviceID: Int, enabled: Int, tdcRange: Int, completion: @escaping (Error?) -> Void)
    {
        DeviceAPI.setDevicePitTempAlarm(deviceID: deviceID, enabled: enabled, tdcRange: tdcRange, completion: completion)
    }
    
    public static func setDeviceMeatAlarm(deviceID: Int, index: Int, mode: Int, tdcTemperature: Int,
                                          tdcWarmTemperature: Int, completion: @escaping (Error?) -> Void)
    {
        DeviceAPI.setDeviceMeatAlarm(deviceID: deviceID, index: index, mode: mode, tdcTemperature: tdcTemperature,
                                     tdcWarmTemperature: tdcWarmTemperature, completion: completion)
    }
    
    
    // MARK: Cook
    public static func getUserCookHistory(completion: @escaping ([Cook]?, Error?) -> Void)
    {
        CookAPI.getUserCookHistory(completion: completion)
    }
    
    public static func getCook(cookID: Int, skipCount: Int = 0, completion: @escaping (Cook?, Error?) -> Void)
    {
        CookAPI.getCook(cookID: cookID, skipCount: skipCount, completion: completion)
    }
    
    public static func updateCook(cookID: Int, title: String = "", notes: String = "", keep: Bool = true,
        completion: @escaping (Error?) -> Void)
    {
        CookAPI.updateCook(cookID: cookID, title: title, notes: notes, keep: keep, completion: completion)
    }
    
    public static func deleteCook(cookID: UInt, completion: @escaping (Error?) -> Void)
    {
        CookAPI.deleteCook(cookID: cookID, completion: completion)
    }
}
