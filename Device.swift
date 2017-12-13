//
//  Device.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 3/6/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation
import RealmSwift
import Gloss

class Device : Object, Gloss.Decodable
{
    dynamic var id: Int = 0
    dynamic var name: String? = nil
    dynamic var online: Bool = false
    dynamic var mostRecentCook: Cook? = nil
    dynamic var minSetTempTdc: Int = 0
    dynamic var maxSetTempTdc: Int = 0
    dynamic var pin: Int = 0
    dynamic var config: DeviceConfigData? = nil
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(json: JSON)
    {
        self.init()
        
        guard let id: Int = "id" <~~ json,
            let online: Bool = "online" <~~ json,
            let minSetTempTdc: Int = "min_set_temp_tdc" <~~ json,
            let maxSetTempTdc: Int = "max_set_temp_tdc" <~~ json
            else { return nil }
        
        name = "name" <~~ json
        
        self.id = id
        self.online = online
        self.mostRecentCook = "most_recent_cook" <~~ json
        self.minSetTempTdc = minSetTempTdc
        self.maxSetTempTdc = maxSetTempTdc
        if let configDict: [String : Int] = "config" <~~ json
        {
            self.config = DeviceConfigData(configDict: configDict)
        }
    }
    
    public func getName() -> String
    {
        var deviceName : String
        if((name ?? "").isEmpty){
            deviceName = "Controller \(id)"
        }
        else{
            deviceName = name!
        }

        return deviceName
    }
    
    public func getSoundSetting() -> DeviceSoundSetting
    {
        guard let config = config else { return .Silent }
        return config.getSoundSetting()
    }
    
    public func isPitAlarmEnabled() -> Bool
    {
        guard let config = config else { return false }
        return config.pit_alarm_enabled == 1 ? true : false
    }
    
    public func pitAlarmRangeTdc() -> Int?
    {
        return config?.pit_alarm_range_tdc
    }
    
    public func meatAlarmWarmTempTdc() -> Int?
    {
        guard let config = config else { return nil }
        return config.meat_alarm_warm_tdc
    }
    
    public func meatAlarmActions() -> [Int]?
    {
        guard let config = config else { return nil }
        return [config.meat1_alarm_action, config.meat2_alarm_action, config.meat3_alarm_action]
    }
    
    public func meatAlarmTempsTdc() -> [Int]?
    {
        guard let config = config else { return nil }
        return [config.meat1_alarm_temp_tdc, config.meat2_alarm_temp_tdc, config.meat3_alarm_temp_tdc]
    }
    
    public func diffLimitTdcRange() -> (lowest: Int, highest: Int) { return (83, 255) }
}
