//
//  UserDataStore.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 2/23/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation
import RealmSwift

class UserDataStore : NSObject
{
    
    public static func getDevices() -> [Device]
    {
        let realm = try! Realm()
        
        let devices = realm.objects(Device.self)
        
        return Array(devices)
    }

    public static func getServerIndex() -> Int
    {
        if let server : Int = UserDefaults.standard.value(forKey: UserDefaultKeys.server) as? Int
        { return server }

        return 0
    }

    public static func getUsername() -> String
    {
        if let username = UserDefaults.standard.value(forKey: UserDefaultKeys.username) as? String
        { return username }
        
        return ""
    }
    
    public static func getAuthToken() -> String
    {
        if let authToken = UserDefaults.standard.value(forKey: UserDefaultKeys.authToken) as? String
        { return authToken }
        
        return ""
    }
    
    public static func getDeviceID() -> UInt
    {
        if let deviceID = UserDefaults.standard.value(forKey: UserDefaultKeys.deviceID) as? UInt
        { return deviceID }
        
        return 0
    }
    
    public static func isUserLoggedIn() -> Bool
    {
        return !getUsername().isEmpty && !getAuthToken().isEmpty
    }
    
    public static func isFirstTimeUsingApp() -> Bool
    {
        if let firstTime = UserDefaults.standard.value(forKey: UserDefaultKeys.firstTimeUsingApp) as? Bool
        { return firstTime }
        
        return true
    }
}
