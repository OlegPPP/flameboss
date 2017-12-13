//
//  DeviceMessage.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 2/22/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation

public struct DeviceMessage
{
    var header = DeviceMessageHeader()
    var payload : [UInt8] = []
    
    func encode() -> [UInt8]
    {
        var bytes : [UInt8]
        
        header.timeSecs = MyUInt32(UInt32(Date().timeIntervalSince1970))
        header.payloadLengthInBytes = payload.count
        bytes = header.encode()
        
        if (header.payloadLengthInBytes > 0)
            { bytes += payload }
        
        return bytes
    }
}
