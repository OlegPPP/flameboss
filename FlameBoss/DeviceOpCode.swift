//
//  DeviceOpCode.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 2/22/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

enum DeviceOpCode : UInt16
{
    case d_RESERVED = 0x0000
    case d_SET_TIME = 0x0001
    case d_HEARTBEAT = 0x0002
    case d_PING = 0x0003
    case d_PONG = 0x0004
    case d_ADC_CTRL = 0x0005
    case d_RESET = 0x000A
    case d_DL_START = 0x0201
    case d_DL_BLOCK = 0x0202
    case d_SET_SETPOINT = 0x0301
    case d_SET_MEAT_ALARM = 0x0302
    case d_SET_WIFI_CONFIG = 0x0303
    case d_SET_PIT_ALARM = 0x0304
    case d_SET_SOUND = 0x0305
    case d_ALERT_MSG = 0x0401
    case d_SHUTDOWN = 0x0501
    case d_WRITE = 0x0601
    case d_READ = 0x0602
    case d_CONSOLE_CTRL = 0x0071
    case d_CONSOLE_DATA = 0x0072
    case u_START = 0x8000
    case u_CONFIG = 0x8001
    case u_DATA = 0x8002
    case u_PING = 0x8003
    case u_PONG = 0x8004
    case u_DL_ACK = 0x8011
    case u_ERROR_MSG = 0x8021
    case u_HEARTBEAT = 0x8031
    case u_SHUTDOWN = 0x8041
    case u_MEAT_ALARM = 0x8051
    case u_PIT_ALARM = 0x8052
    case u_BATTERY_LOW = 0x8053
    case u_PIT_ALARM_ACTIVE = 0x8054
    case u_VENT_ADVICE = 0x8055
    case u_OPEN_PIT = 0x8056
    case u_LEARNED = 0x8057
    case u_WIFI_LIST = 0x8058
    case u_WRITE_RES = 0x8061
    case u_READ_RES = 0x8062
    case u_CONSOLE_DATA = 0x8072
    case u_SET_WIFI_ACK = 0x8303
    case u_SET_SOUND_ACK = 0x8305
    case u_END_COOK = 0x1001
    
    // New Downlink Messages
    case d_DIRECT_START = 0x000E
    case d_WIFI_LIST = 0x000D
}
