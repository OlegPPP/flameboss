//
//  DeviceAPI.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 6/16/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation

class DeviceAPI : NSObject
{
    static var addedDevices = [Device]()
    static var localDevices = [Device]()

    public static func deviceIsOwned(deviceID: Int) -> Bool
    {
        for device in addedDevices {
            if (device.id == deviceID) {
                return true
            }
        }
        return false
    }

    public static func setDeviceWifi(deviceID: Int, wifiName: String, securityType: WifiSecurityType,
                                     password: String, completion: @escaping (Error?) -> Void)
    {
        let urlEnding = "/api/v1/devices/" + String(deviceID) + "/set_wifi"
        let urlBody = "ssid=" + wifiName + "&sec_type=" + String(securityType.rawValue) + "&key=" + password
        
        APICommon.runRequest(urlEnding: urlEnding, method: .POST, body: urlBody) { (jsonDict, error) in
            
            if error != nil { completion(error); return }
            let result = APICommon.statusFromJsonDict(jsonDict!, errorMessage: "Could not set controller wifi.")
            completion(result)
        }
    }
    
    public static func setDeviceSound(deviceID: Int, soundSetting: DeviceSoundSetting,
                                      completion: @escaping (Error?) -> Void)
    {
        let urlEnding = "/api/v1/devices/" + String(deviceID) + "/set_sound"
        let urlBody = "sound=" + String(soundSetting.rawValue)
        
        APICommon.runRequest(urlEnding: urlEnding, method: .POST, body: urlBody) { (jsonDict, error) in
            
            if error != nil { completion(error); return }
            let result = APICommon.statusFromJsonDict(jsonDict!, errorMessage: "Could not set conroller sound.")
            completion(result)
        }
    }
    
    public static func updateDeviceName(deviceID: Int, newName: String, completion: @escaping (Error?) -> Void)
    {
        let urlEnding = "/api/v1/devices/" + String(deviceID)
        let urlBody = "device[name]=" + newName
        
        APICommon.runRequest(urlEnding: urlEnding, method: .PATCH, body: urlBody) { (jsonDict, error) in
            
            if error != nil { completion(error); return }
            let result = APICommon.statusFromJsonDict(jsonDict!, errorMessage: "Could not update controller name.")
            completion(result)
        }
    }
    
    public static func setDeviceTemperature(deviceID: Int, tdcTemperature: Int, completion: @escaping (Error?) -> Void)
    {
        let urlEnding = "/api/v1/devices/" + String(deviceID) + "/set_set_temp"
        let urlBody = "temp_tdc=" + String(tdcTemperature)
        
        APICommon.runRequest(urlEnding: urlEnding, method: .POST, body: urlBody) { (jsonDict, error) in
            
            guard error == nil else { completion(error); return }
            let result = APICommon.statusFromJsonDict(jsonDict!, errorMessage: "Could not change set temp.")
            completion(result)
        }
    }
    
    public static func getDevices(completion: @escaping (DevicesIndex?, Error?) -> Void)
    {
        let urlEnding = "/api/v1/devices"
        
        APICommon.runRequest(urlEnding: urlEnding, method: .GET) { (jsonDict, error) in
            
            guard error == nil else
            {
                completion(nil, APICommon.errorFromMessage((error?.localizedDescription)!)); return
            }
            
            guard let devicesIndex = DevicesIndex(json: jsonDict!) else
            {
                completion(nil, APICommon.errorFromMessage("Could not get devices.")); return
            }

            addedDevices = devicesIndex.devices

            localDevices = devicesIndex.ipDevices
            
            completion(devicesIndex, nil)
        }
    }
    
    public static func getDevice(deviceID: Int, completion: @escaping (Device?, Error?) -> Void)
    {
        let urlEnding = "/api/v1/devices/" + String(deviceID)
        
        APICommon.runRequest(urlEnding: urlEnding, method: .GET) { (jsonDict, error) in
            guard error == nil else
            {
                completion(nil, APICommon.errorFromMessage((error?.localizedDescription)!)); return
            }
            
            guard let device = Device(json: jsonDict!) else
            {
                completion(nil, APICommon.errorFromMessage("Could not get device.")); return
            }
            
            completion(device, nil)
        }
    }
    
    public static func setDevicePitTempAlarm(deviceID: Int, enabled: Int, tdcRange: Int, completion: @escaping (Error?) -> Void)
    {
        let urlEnding = "/api/v1/devices/" + String(deviceID) + "/set_pit_alarm"
        let urlBody = "en=" + String(enabled) + "&range_tdc=" + String(tdcRange)
        
        APICommon.runRequest(urlEnding: urlEnding, method: .POST, body: urlBody) { (jsonDict, error) in
            
            if error != nil { completion(error); return }
            let result = APICommon.statusFromJsonDict(jsonDict!, errorMessage: "Could not change pit temp alarm.")
            completion(result)
        }
    }
    
    public static func setDeviceMeatAlarm(deviceID: Int, index: Int, mode: Int, tdcTemperature: Int,
                                          tdcWarmTemperature: Int, completion: @escaping (Error?) -> Void)
    {
        let urlEnding = "/api/v1/devices/" + String(deviceID) + "/set_meat_alarm"
        let urlBody = "index=" + String(index) + "&mode=" + String(mode) + "&temp_tdc=" + String(tdcTemperature) +
            "&warm_tdc=" + String(tdcWarmTemperature)
        
        APICommon.runRequest(urlEnding: urlEnding, method: .POST, body: urlBody) { (jsonDict, error) in
            
            if error != nil { completion(error); return }
            let result = APICommon.statusFromJsonDict(jsonDict!, errorMessage: "Could not set device meat alarm.")
            completion(result)
        }
    }
    
    public static func addDevice(deviceID: UInt, pin: UInt, serialNumber: UInt, completion: @escaping (Error?) -> Void)
    {
        let urlEnding = "/api/v1/devices/" + String(deviceID) + "/add"
        let urlBody = "device[pin]=" + String(pin) + "&device[sn]=" + String(serialNumber)
        
        APICommon.runRequest(urlEnding: urlEnding, method: .POST, body: urlBody) { (jsonDict, error) in
            
            if error != nil { completion(error); return }
            let result = APICommon.statusFromJsonDict(jsonDict!, errorMessage: "Could not add smoker controller.")
            completion(result)
        }
    }
    
    public static func removeDevice(deviceID: Int, completion: @escaping (Error?) -> Void)
    {
        let urlEnding = "/api/v1/devices/" + String(deviceID) + "/remove"
        
        APICommon.runRequest(urlEnding: urlEnding, method: .POST) { (jsonDict, error) in
            
            if error != nil { completion(error); return }
            let result = APICommon.statusFromJsonDict(jsonDict!, errorMessage: "Could not remove smoker controller.")
            completion(result)
        }
    }
}
