//
//  GeneralSensorConfiguration.swift
//  nervousnet-HUB-iOS
//
//  Created by Enz  Andreas on 14.12.16.
//  Copyright © 2016 ETH Zurich - COSS. All rights reserved.
//

import Foundation

class GeneralSensorConfiguration {
    
    // Fix the possible config types in an enmum
    enum sType {
        case int_t
        case double_t
        case string_t
    }
    
    public private(set) var sensorID : UInt64 //getter: public, setter: private
    public private(set) var sensorName : String
    public private(set) var parameterDef : [(name: String, type: sType)]
    
    init(sensorID : UInt64, sensorName : String, parameterDef : [(name: String, type: sType)]) {
        self.sensorID = sensorID
        self.sensorName = sensorName
        self.parameterDef = parameterDef
    }
    
    public var parameterDim : Int {
        get {
            return parameterDef.count
        }
    }
    
    
}
