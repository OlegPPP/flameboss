//
//  SmokerDeviceCommunicator.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 2/24/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation

class SmokerDeviceCommunicator : NSObject, StreamDelegate
{
    private let serverAddress = "192.168.4.1" as CFString
    private let serverPort : UInt32 = 9997
    
    private var inputStream: InputStream!
    private var outputStream: OutputStream!
    
    private var settingWifi: Bool = false
    private var receivingPayload = false
    private var message = DeviceMessage()
    private var readLength = 0
    private var wifiSecurityType = WifiSecurityType.unsecure
    private var wifiSsid = ""
    private var wifiKey = ""
    private var headerBuffer = [UInt8](repeating: 0, count: 20)
    private var payloadBuffer = [UInt8](repeating: 0, count: 1024)
    
    private var getAccessPointsAvailableCompletion: (([AccessPoint], NSError?) -> Void) = { (accessPoints, error) in }
    private var setWifiCompletion: (NSError?) -> Void = { (error) in }
    private var tryConnectingCompletion: (NSError?) -> Void = { (error) in }
    
    
    // Flame Boss can only be one type of server at a time and it starts out
    // being a tiny http server only for the purpose of setting up wifi more easily.
    // This special request will switch the server to the Flame Boss protocol
    private func switchToFlameBossProtocol()
    {
        if let url = URL(string: "http://\(serverAddress)/switch")
        {
            let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            })
            task.resume();
        }
    }
    
    public func getAccessPointsAvailable(completion: @escaping ([AccessPoint], NSError?) -> Void)
    {
        getAccessPointsAvailableCompletion = completion
        sendMessage(opCode: DeviceOpCode.d_WIFI_LIST)
    }
    
    public func setWifi(accessPoint: AccessPoint, key: String, completion: @escaping(NSError?) -> Void)
    {
        wifiSsid = accessPoint.ssid
        wifiKey = key
        wifiSecurityType = accessPoint.securityType
        setWifiCompletion = completion
        settingWifi = true
        sendMessage(opCode: DeviceOpCode.d_SET_WIFI_CONFIG)
    }
    
    public func tryConnecting(completion: @escaping (NSError?) -> Void)
    {
        switchToFlameBossProtocol()
        self.tryConnectingCompletion = completion
        connectAfterDelay(seconds: 2)
    }
    
    private func connectAfterDelay(seconds: TimeInterval)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.connect()
        }
    }
    
    func connect()
    {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil, serverAddress, serverPort, &readStream, &writeStream)
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.delegate = self
        outputStream.delegate = self
        
        inputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        outputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        
        inputStream.open()
        outputStream.open()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.sendMessage(opCode: DeviceOpCode.d_DIRECT_START)
        }
    }
    
    public func disconnect()
    {
        if inputStream != nil { inputStream.close() }
        if outputStream != nil { outputStream.close() }
        inputStream = nil
        outputStream = nil
    }
    
    func stream(_ stream: Stream, handle eventCode: Stream.Event)
    {
        guard inputStream != nil && outputStream != nil else { return }
        
        if stream == inputStream
        {
            switch eventCode
            {
            case Stream.Event.errorOccurred:
                print("input stream: error occurred")
                if settingWifi
                {
                    disconnect()
                    setWifiCompletion(nil)
                }
                else
                {
                    print("trying to connect again.\n")
                    disconnect()
                    connect()
                }
                
            case Stream.Event.openCompleted:
                print("input stream: open completed")
                tryConnectingCompletion(nil)
                
            case Stream.Event.hasBytesAvailable:
                print("input stream: has bytes available")
                
                while inputStream.hasBytesAvailable
                {
                    if receivingPayload
                    {
                        let payloadLength = message.header.payloadLengthInBytes
                        let length = inputStream.read(&payloadBuffer[readLength], maxLength: payloadLength - readLength)
                        
                        readLength += length
                        if readLength == payloadLength
                        {
                            message.payload = Array(payloadBuffer[0...message.header.payloadLengthInBytes - 1])
                            receiveMessage()
                            readLength = 0
                            receivingPayload = false
                        }
                    }
                    else
                    {
                        let length = inputStream.read(&headerBuffer[readLength], maxLength: 20 - readLength)
                        readLength += length
                        
                        if readLength == 20
                        {
                            message.header.decode(headerBuffer)
                            if message.header.payloadLengthInBytes == 0
                            {
                                receiveMessage()
                            }
                            else
                            {
                                receivingPayload = true
                            }
                            readLength = 0
                        }
                    }
                }
                
            default:
                break
            }
        }
        
        else if stream == outputStream
        {
            switch eventCode
            {
            case Stream.Event.errorOccurred:
                print("output stream: error occurred")
                
            case Stream.Event.openCompleted:
                print("output stream: open completed")
                
            case Stream.Event.hasSpaceAvailable:
                print("output stream: has space available")
                
            default:
                break
            }
        }
    }
    
    private func sendMessage(opCode: DeviceOpCode)
    {
        guard outputStream != nil else { return }
        
        var message = DeviceMessage()
        message.header.opCode = opCode
        
        switch (opCode)
        {
        case DeviceOpCode.d_DIRECT_START:
            message.header.args[0] = MyUInt32(1)
            
        case DeviceOpCode.d_WIFI_LIST:
            message.header.args[0] = MyUInt32(1)
            
        case DeviceOpCode.d_SET_TIME:
            message.header.args[0] = MyUInt32(UInt32(Date().timeIntervalSince1970))
            message.header.args[1] = MyUInt32(1)
            message.header.args[2] = MyUInt32(0)
            
        case DeviceOpCode.d_SET_WIFI_CONFIG:
            let wifiConfig = AccessPointConfiguration(ssid: wifiSsid, key: wifiKey, secType: wifiSecurityType)
            message.payload = wifiConfig.encode()
            
        case DeviceOpCode.d_RESET:
            message.header.args[0] = MyUInt32(1)
            
        default:
            break
        }
        
        let bytes: [UInt8] = message.encode()
        outputStream.write(bytes, maxLength: bytes.count)
    }
    
    private func receiveMessage()
    {
        print("received message opcode: \(message.header.opCode)")
        
        switch (message.header.opCode)
        {
        case DeviceOpCode.u_START:
            break
//            sendMessage(opCode: DeviceOpCode.d_WIFI_LIST)
            
        case DeviceOpCode.u_WIFI_LIST:
            if !settingWifi
            {
                let accessPoints = AccessPoint.decode(message: message)
                //sendMessage(opCode: DeviceOpCode.d_SHUTDOWN)
                
                self.getAccessPointsAvailableCompletion(accessPoints, nil)
            }
            else
            {
                //sendMessage(opCode: DeviceOpCode.d_SET_WIFI_CONFIG)
            }
        case DeviceOpCode.u_SET_WIFI_ACK:
            // sendMessage(opCode: DeviceOpCode.d_RESET)
            // call wifi completion block
            break
            
        case DeviceOpCode.u_DATA:
            break
            
        default:
            break
        }
    }
}
