//
//  AccessPointConfiguration.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 2/22/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation

public struct AccessPointConfiguration
{
    public let ssid : String
    public let key : String
    public let wifiSecurityType : WifiSecurityType
    
    public func encode() -> [UInt8]
    {
        var a : [UInt8] = []
        a.append(wifiSecurityType.rawValue)
        
        var strBytes = [UInt8](repeating: 0, count: 33)
        for (index, element) in ssid.utf8.enumerated()
        {
            strBytes[index] = element
        }
        a += strBytes
        
        strBytes = [UInt8](repeating: 0, count: 66)
        for (index, element) in key.utf8.enumerated()
        {
            strBytes[index] = element
        }
        a += strBytes
        return a
    }
    
    public init(ssid : String, key : String, secType : WifiSecurityType)
    {
        self.ssid = ssid
        self.key = key
        self.wifiSecurityType = secType
    }
}

public enum WifiSecurityType : UInt8
{
    case unsecure = 0
    case wep = 1
    case wpa = 2
    case wpa2 = 3
}
