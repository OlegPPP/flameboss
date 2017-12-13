//
//  WebSocket.swift
//  Flame Boss
//
//  Created by Roger Collins on 12/25/16.
//  Copyright © 2016 Roger Collins. All rights reserved.
//

import Foundation
import Gloss
import SwiftWebSocket


public func parseJSON(inputData: Data) throws -> NSArray {
    let a: NSArray = try JSONSerialization.jsonObject(with: inputData) as! NSArray
    return a
}

open class WsRails {
    var channels = [String : WsRailsChannel]()
    var callbacks : [String : (String, Dictionary<String, Any>) -> Void] = [:]
    let ws : WebSocket
    var userClosedSocket = false
    
    public func closeWebSocket()
    {
        ws.close()
    }
    
    public func openWebSocket()
    {
        ws.open()
    }
    
    init(url : String) {
        print("FB_WS: \(url)")
        ws = WebSocket(url)
        
        ws.event.open = {
            print("WS opened")
        }
        ws.event.close = { code, reason, clean in
            
            print("WS close. Code: \(code) Reason: \(reason)")
            self.postWebsocketClosedNotification()
        }
        ws.event.error = { error in
            print("WS error \(error)")
            self.ws.close()
        }
        ws.event.message = { message in
            if let text = message as? String {
                do {
                    let data = text.data(using: .utf8)
                    let obj = try parseJSON(inputData: data!)
                    let a = obj[0] as! [Any]
                    self.new_message(data: a)
                }
                catch {
                    print("ws.event.message error")
                }
            }
        }
    }
    
    private func postWebsocketClosedNotification()
    {
        let notificationCenter = NotificationCenter.default
        notificationCenter.post(Notification(name: Notification.Name(rawValue: "WebSocketClosed")))
    }
    
    func new_message(data: [Any]) {
        let event = WsRailsEvent(data: data, dispatcher: self)
        if event.is_ping() {
            pong()
        }
        if event.channel != nil {
            // process as a channel event
            let channel = self.channels[event.channel!]
            if channel == nil {
                print("error: no channel for event")
            }
            else {
                channel!.dispatch(event: event)
            }
        }
        else {
            // process as a direct event
            let cb = self.callbacks[event.name]
            if cb != nil {
                print("FB_WS: \(event.name)")
                cb!(event.name, event.app_data)
            }
        }
    }
    
    func pong() -> Void {
        let event = WsRailsEvent(data: ["websocket_rails.pong", Dictionary<String, Any>()], dispatcher: self)
        event.trigger()
    }
    
    func subscribe(channelName: String) -> WsRailsChannel {
        if channels[channelName] == nil {
            print("FB_WS: subscribe \(channelName)")
            channels[channelName] = WsRailsChannel(name: channelName, dispatcher: self)
        }
        return channels[channelName]!
    }
    
    func unsubscribe(channelName: String) -> Void {
        channels.removeValue(forKey: channelName)
    }
    
    func bind(eventName: String, callback : @escaping (String, Dictionary<String, Any>) -> Void) -> Void {
        callbacks[eventName] = callback
    }
    
    func trigger(event: WsRailsEvent) {
        let s = event.serialize()
        ws.send(s)
    }
}
