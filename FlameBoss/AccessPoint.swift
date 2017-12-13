//
//  AccessPoint.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 2/24/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation

public struct AccessPoint
{
    public let ssid: String
    public let securityType: WifiSecurityType
    
    public init(ssid: String, securityType: WifiSecurityType)
    {
        self.ssid = ssid
        self.securityType = securityType
    }
    
    public static func decode(message: DeviceMessage) -> [AccessPoint]
    {
        var accessPoints = [AccessPoint]()
        var index = 0
        var ssid = ""
        
        while index < message.header.payloadLengthInBytes
        {
            if message.payload[index] == 0
            {
                let securityType = WifiSecurityType(rawValue: message.payload[index + 1])
                accessPoints.append(AccessPoint(ssid: ssid, securityType: securityType!))
                index += 2
                ssid = ""
            }
            else
            {
                ssid.append(Character(UnicodeScalar(message.payload[index])))
                index += 1
            }
        }
        
        return accessPoints
    }
}
