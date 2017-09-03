//
//  Constants.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 11.01.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import Foundation
import SQLite

struct Constants {
    
    // the names need to match the names of an entry with 'sensorName' in sensors_configuration.json
    // TODO: change interface such that adding new axon here does not require adding new viewcontroller
    static let PREINSTALLED_AXON_NAMES = ["Accelerometer", "Gyroscope", "Magnetometer"]
    
    static let SERVER_STATE_KEY = "serverstate"
    static let SERVER_STATE_DEFAULT = VMConstants.STATE_PAUSED
    static let SERVER_CONFIG_KEY = "serverconfig"
    static let SERVER_CONFIG_KEYS = ["applicationId", "server", "isLocalDatastoreEnabled" ]
    static let SERVER_CONFIG_DEFAULTS : [String:Any] = ["applicationId" : "nervousnet",
                                       "server" : "http://207.154.242.197:1337/parse",
                                       "isLocalDatastoreEnabled" : true]

    
}
