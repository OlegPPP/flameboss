//
//  CookData.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 3/6/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Gloss
import RealmSwift

class CookData : Object, Gloss.Decodable
{
    dynamic var count: Int = 0
    dynamic var sec: Int = 0
    dynamic var setTemperature: Int = 0
    dynamic var pitTemperature: Int = 0
    var meatTemperatures: List<IntObject> = List<IntObject>()
    dynamic var fanDc: Int = 0
    
    required convenience init?(json: JSON)
    {
        self.init()
        
        guard let sec: Int = "sec" <~~ json,
            let setTemperature: Int = "set_temp" <~~ json,
            let pitTemperature: Int = "pit_temp" <~~ json,
            let meatTempsArray: [Int] = "meat_temps" <~~ json,
            let fanDc: Int = "fan_dc" <~~ json
        else { return nil }

        let count: Int? = "cnt" <~~ json

        for meatTemp in meatTempsArray
        {
            meatTemperatures.append(IntObject(meatTemp))
        }

        self.count = count == nil ? 0 : count!
        self.sec = sec
        self.setTemperature = setTemperature
        self.pitTemperature = pitTemperature
        self.fanDc = fanDc
    }
}
