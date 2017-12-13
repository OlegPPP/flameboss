//
//  WsRailsEvent.swift
//  Flame Boss
//
//  Created by Roger Collins on 12/25/16.
//  Copyright © 2016 Roger Collins. All rights reserved.
//

import Foundation


open class WsRailsEvent {
    let dispatcher : WsRails
    let id : UInt32
    let name : String
    let app_data : Dictionary<String, Any>
    let token : String?
    let connection_id : String?
    let channel : String?
    
    init(data: [Any], dispatcher: WsRails) {
        self.dispatcher = dispatcher
        
        name = data[0] as! String
        let attr = data[1] as! Dictionary<String, Any>
        
        id = arc4random()
        
        channel = attr["channel"] as? String
        
        let app_data = attr["data"] as? Dictionary<String, Any>
        if app_data == nil {
            self.app_data = [:]
        } else {
            self.app_data = app_data!
        }
        
        if name == "client_connected" {
            connection_id = (app_data!["connection_id"] as? String)
        }
        else {
            connection_id = nil
        }
        
        token = attr["token"] as? String
        
        // xxx attr["success"] ?
    }
    
    open func serialize() -> String {
        var attrs : [ String : Any ] = [ "id" : id ]
        if channel != nil {
            attrs["channel"] = channel!
        }
        if token != nil {
            attrs["token"] = token!
        }
        attrs["data"] = app_data
        
        let obj : [ Any ] = [ name, attrs ]
        do {
            let data = try JSONSerialization.data(withJSONObject: obj)
            let s = String(data: data, encoding: .utf8)
            return s!
        } catch {
            return ""
        }
    }
    
    open func trigger() -> Void {
        dispatcher.trigger(event: self)
    }
    
    open func is_ping() -> Bool {
        return name == "websocket_rails.ping"
    }
    
    open func is_channel_token() -> Bool {
        return name == "websocket_rails.channel_token"
    }
}
