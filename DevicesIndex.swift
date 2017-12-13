//
//  DevicesIndex.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 3/6/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation
import Gloss

class DevicesIndex : Gloss.Decodable
{
    var username: String
    var devices: [Device]
    var ipDevices: [Device]
    var ipAddress: String
    
    required init?(json: JSON)
    {
        guard let username: String = "username" <~~ json,
        let devices: [Device] = "devices" <~~ json,
        let ipDevices: [Device] = "ip_devices" <~~ json,
        let ipAddress: String = "ip_address" <~~ json
        else { return nil }
        
        self.username = username
        self.devices = devices
        self.ipDevices = ipDevices
        self.ipAddress = ipAddress
    }
}


































































