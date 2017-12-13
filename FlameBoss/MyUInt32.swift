//
//  MyUInt32.swift
//  FlameBoss
//
//  Created by Roger Collins on 8/22/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation

class MyUInt32
{
    var i : UInt32 = 0

    init(_ a : UInt32)
    {
        i = a
    }

    init(bytes : [UInt8])
    {
        i = UInt32(bytes[0]) | (UInt32(bytes[1]) << 8) | (UInt32(bytes[2]) << 16) | (UInt32(bytes[3]) << 24)
    }

    public func encode() -> [UInt8]
    {
        return [ UInt8(i & 0xff), UInt8((i >> 8) & 0xff), UInt8((i >> 16) & 0xff), UInt8((i >> 24) & 0xff) ]
    }

    public func toUInt32() -> UInt32
    {
        return i
    }
}
