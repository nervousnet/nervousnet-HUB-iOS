//
//  VMConstants.swift
//  nervousnet-HUB-iOS
//
//  Created by Enz  Andreas on 21.12.16.
//  Copyright © 2016 ETH Zurich - COSS. All rights reserved.
//

import Foundation

public class VMConstants {

    /*
    enum NervousState {
        case RUNNING
        case PAUSED
    }
    */
    
    
    
    
    static var STATE_PAUSED : Int = 0
    static var STATE_RUNNING : Int = 1
    
    static var SENSOR_STATE_NOT_AVAILABLE : Int = -2
    static var SENSOR_STATE_AVAILABLE_PERMISSION_DENIED : Int = -2
    static var SENSOR_STATE_AVAILABLE_BUT_OFF : Int = 0
    static var SENSOR_STATE_AVAILABLE_DELAY_LOW : Int = 1
    static var SENSOR_STATE_AVAILABLE_DELAY_MED : Int = 2
    static var SENSOR_STATE_AVAILABLE_DELAY_HIGH : Int = 3

    
    
    static var sensor_labels : [String] = ["ACCELEROMETER", "BATTERY", "GYROSCOPE", "LOCATION", "LIGHT", "NOISE", "PROXIMITY"]
    static var sensor_freq_labels : [String] = ["Off", "Low", "Medium", "High"]
    
    static var EVENT_PAUSE_NERVOUSNET_REQUEST : Int = 0
    static var EVENT_START_NERVOUSNET_REQUEST : Int = 1
    static var EVENT_CHANGE_SENSOR_STATE_REQUEST : Int = 2
    static var EVENT_CHANGE_ALL_SENSORS_STATE_REQUEST : Int = 3
    static var EVENT_NERVOUSNET_STATE_UPDATED : Int = 4
    static var EVENT_SENSOR_STATE_UPDATED : Int = 5

    
}
