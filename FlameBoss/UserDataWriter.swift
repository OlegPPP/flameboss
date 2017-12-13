//
//  UserDataWriter.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 2/23/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation
import RealmSwift

class UserDataWriter : NSObject
{
    public static func setFirstTimeUsingApp(_ firstTime: Bool)
    {
        UserDefaults.standard.set(firstTime, forKey: UserDefaultKeys.firstTimeUsingApp)
        synchronize()
    }
    
    public static func saveDevices(_ devices: [Device])
    {
        for device in devices { saveDevice(device) }
    }
    
    public static func saveDevice(_ device: Device)
    {
        writeObjectToRealm(device, update: true)
    }
    
    private static func writeObjectToRealm(_ object: Object, update: Bool)
    {
        let realm = try! Realm()
        realm.beginWrite()
        realm.add(object, update: update)
        try! realm.commitWrite()
    }
    
    public static func updateDeviceName(deviceID: Int, name: String)
    {
        let devices = UserDataStore.getDevices()
        for device in devices
        {
            if device.id == deviceID
            {
                let realm = try! Realm()
                realm.beginWrite()
                device.name = name
                try! realm.commitWrite()
                return
            }
        }
    }
    
    public static func removeAllDevices()
    {
        let devices = UserDataStore.getDevices()
        removeDevices(devices)
    }
    
    public static func removeDevices(_ devices: [Device])
    {
        for device in devices
        {
            removeDevice(device)
        }
    }
    
    public static func removeDevice(_ device: Device)
    {
        removeObjectFromRealm(device)
    }
    
    private static func removeObjectFromRealm(_ object: Object)
    {
        let realm = try! Realm()
        realm.beginWrite()
        realm.delete(object)
        try! realm.commitWrite()
    }

    public static func saveServerIndex(_ serverIndex: Int)
    {
        UserDefaults.standard.set(serverIndex, forKey: UserDefaultKeys.server)
        synchronize()
    }
    
    public static func saveUsername(_ username: String)
    {
        UserDefaults.standard.set(username, forKey: UserDefaultKeys.username)
        synchronize()
    }
    
    public static func saveAuthToken(_ authToken: String)
    {
        UserDefaults.standard.set(authToken, forKey: UserDefaultKeys.authToken)
        synchronize()
    }
    
    public static func removeUsernameAndAuthToken()
    {
        UserDefaults.standard.set("", forKey: UserDefaultKeys.username)
        UserDefaults.standard.set("", forKey: UserDefaultKeys.authToken)
        synchronize()
    }
    
    public static func saveDeviceID(_ deviceID: UInt)
    {
        UserDefaults.standard.set(deviceID, forKey: UserDefaultKeys.deviceID)
        synchronize()
    }
    
    public static func removeDeviceID()
    {
        UserDefaults.standard.set(0, forKey: UserDefaultKeys.deviceID)
        synchronize()
    }
    
    private static func synchronize() { UserDefaults.standard.synchronize() }
}
