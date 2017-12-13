//
//  IntObject.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 3/21/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import RealmSwift

class IntObject : Object
{
    dynamic var intValue = 0
    
    convenience init(_ intValue: Int)
    {
        self.init()
        self.intValue = intValue
    }
}
