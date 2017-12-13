//
//  DeviceConfigData.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 6/7/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Gloss

class DeviceConfigData : Object
{
    dynamic var eeprom_format_version: Int = 0
    dynamic var sound: Int = 0
    dynamic var set_temp_tdc: Int = 0
    dynamic var meat1_alarm_action: Int = 0
    dynamic var meat2_alarm_action: Int = 0
    dynamic var meat3_alarm_action: Int = 0
    dynamic var meat1_alarm_temp_tdc: Int = 0
    dynamic var meat2_alarm_temp_tdc: Int = 0
    dynamic var meat3_alarm_temp_tdc: Int = 0
    dynamic var meat_alarm_warm_tdc: Int = 0
    dynamic var pit_alarm_enabled: Int = 0
    dynamic var pit_alarm_range_tdc: Int = 0
    
    required convenience init(configDict: [String: Int])
    {
        self.init()
        
        self.eeprom_format_version = configDict["EEPROM_Format_Version"]!
        self.sound = configDict["Sound"]!
        self.set_temp_tdc = configDict["Set_Temp_tdC"]!
        self.meat1_alarm_action = configDict["Meat_Alarm_Actions[0]"]!
        self.meat2_alarm_action = configDict["Meat_Alarm_Actions[1]"]!
        self.meat3_alarm_action = configDict["Meat_Alarm_Actions[2]"]!
        self.meat1_alarm_temp_tdc = configDict["Meat_Alarm_Temps_tdc[0]"]!
        self.meat2_alarm_temp_tdc = configDict["Meat_Alarm_Temps_tdc[1]"]!
        self.meat3_alarm_temp_tdc = configDict["Meat_Alarm_Temps_tdc[2]"]!
        self.pit_alarm_enabled = configDict["Pit_Alarm_En"]!
        self.pit_alarm_range_tdc = configDict["Pit_Alarm_Range_tdc"]!
        self.meat_alarm_warm_tdc = configDict["Meat_Alarm_Warm_tdc"]!
    }
    
    public func getSoundSetting() -> DeviceSoundSetting
    {
        return DeviceSoundSetting(rawValue: sound)!
    }
}
