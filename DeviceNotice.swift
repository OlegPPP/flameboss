//
//  DeviceNotice.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 3/6/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation
import Gloss
import RealmSwift

class DeviceNotice : Object, Gloss.Decodable
{
    dynamic var id: Int = 0
    dynamic var opCode: Int = 0
    var args: List<IntObject> = List<IntObject>()
    dynamic var payload: String = ""
    
    required convenience init?(json: JSON)
    {
        self.init()
        
        guard let id: Int = "id" <~~ json,
            let opCode: Int = "op_code" <~~ json,
            let argsArray: [Int] = "args" <~~ json,
            let payload: String = "payload" <~~ json
            else { return nil }
        
        for arg in argsArray
        {
            args.append(IntObject(value: arg))
        }
        
        self.id = id
        self.opCode = opCode
        self.payload = payload
    }
}
































