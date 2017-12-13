//
//  Channel.swift
//  Flame Boss
//
//  Created by Roger Collins on 12/25/16.
//  Copyright © 2016 Roger Collins. All rights reserved.
//

import Foundation

class WsRailsChannel {
    var callbacks : [String : (String, Dictionary<String, Any>) -> Void] = [:]
    var token : String? = nil
    let dispatcher : WsRails
    let name : String
    
    init(name: String, dispatcher: WsRails) {
        self.name = name
        self.dispatcher = dispatcher
        let event_name = "websocket_rails.subscribe"
        
        let event = WsRailsEvent(data: [event_name, ["data":[ "channel" : name ]]], dispatcher: dispatcher)
        event.trigger()
    }
    
    func bind(eventName: String, callback : @escaping (String, Dictionary<String, Any>) -> Void) -> Void {
        callbacks[eventName] = callback
    }
    
    func dispatch(event: WsRailsEvent) {
        if event.is_channel_token() {
            token = event.app_data["token"] as? String
        }
        
        let cb = callbacks[event.name]
        if cb != nil {
            print("FB_WS: \(name): \(event.name)")
            cb!(event.name, event.app_data)
        }
    }
}
