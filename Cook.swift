//
//  Cook.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 3/6/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Gloss
import RealmSwift

class Cook : Object, Gloss.Decodable
{
    dynamic var id: Int = 0
    dynamic var deviceID: Int = 0
    dynamic var deviceName: String? = nil
    dynamic var createdAt: String = ""
    dynamic var endedAt: String? = nil
    dynamic var title: String? = nil
    dynamic var online: Bool = false
    var notices: List<DeviceNotice> = List<DeviceNotice>()
    dynamic var dataCount: Int = 0
    dynamic var skipCount: Int = 0
    var data: List<CookData> = List<CookData>()
    
    dynamic var updatedAt: String? = nil
    dynamic var keep: Bool = false
    dynamic var notes: String? = ""
    dynamic var imageUpdatedAt: String? = nil
    dynamic var deletedAt: String? = nil
    
    required convenience init?(json: JSON)
    {
        self.init()
        
        guard let id: Int = "id" <~~ json,
        let createdAt: String = "created_at" <~~ json,
        let deviceID: Int = "device_id" <~~ json
            else { return nil }
        
        self.id = id
        self.createdAt = createdAt
        
        if let dataArray: [CookData] = "data" <~~ json
        {
            for data in dataArray { self.data.append(data) }
        }
        if let noticesArray: [DeviceNotice] = "notices" <~~ json
        {
            for notice in noticesArray { self.notices.append(notice) }
        }
        
        self.deviceID = deviceID
        self.endedAt = "ended_at" <~~ json
        self.title = "title" <~~ json
        self.updatedAt = "updated_at" <~~ json
        self.notes = "notes" <~~ json
        self.imageUpdatedAt = "img_updated_at" <~~ json
        self.deletedAt = "deleted_at" <~~ json
        
        if let keep : Bool = "keep" <~~ json { self.keep = keep }
        if let online : Bool = "online" <~~ json { self.online = online }
        if let dataCount : Int = "data_cnt" <~~ json { self.dataCount = dataCount }
        if let skipCount : Int = "skip_cnt" <~~ json { self.skipCount = skipCount }
        if let deviceName : String = "device_name" <~~ json { self.deviceName = deviceName }
    }
    
    public func startDate() -> Date
    {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter.date(from: createdAt)!
    }
    
    public func endDate() -> Date?
    {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = endedAt { return dateFormatter.date(from: date) }
        else { return nil }
    }
}















