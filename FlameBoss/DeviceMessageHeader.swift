//
//  DeviceMessageHeader.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 2/22/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation

class DeviceMessageHeader
{
    var opCode = DeviceOpCode.d_RESERVED
    var payloadLengthInBytes : Int = 0
    var timeSecs : MyUInt32 = MyUInt32(0)
    var args : [MyUInt32] = [MyUInt32(0), MyUInt32(0), MyUInt32(0)]
    
    func decode(_ bytes : [UInt8])
    {
        let opcodeRawValue = UInt16(bytes[1]) << 8 | UInt16(bytes[0])
        guard let optionalOpcode = DeviceOpCode(rawValue: opcodeRawValue) else { return }
        
        opCode = optionalOpcode
        payloadLengthInBytes = Int(UInt16(bytes[3]) << 8 | UInt16(bytes[2]))
        timeSecs = MyUInt32(bytes: bytes)
        args = [MyUInt32(bytes: Array<UInt8>(bytes[8...11])),
                MyUInt32(bytes: Array<UInt8>(bytes[12...15])),
                MyUInt32(bytes: Array<UInt8>(bytes[16...19]))]
    }
    
    func encode() -> [UInt8]
    {
        var bytes : [UInt8] = []
        bytes += [ UInt8(opCode.rawValue & 0xff), UInt8(opCode.rawValue >> 8) ]
        bytes += [ UInt8(payloadLengthInBytes & 0xff), UInt8(payloadLengthInBytes >> 8) ]
        bytes += timeSecs.encode()
        bytes += args[0].encode()
        bytes += args[1].encode()
        bytes += args[2].encode()
        return bytes
    }
}
