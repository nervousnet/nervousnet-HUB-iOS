//
//  GeneralSensorConfiguration.swift
//  nervousnet-HUB-iOS
//
//  Created by Enz  Andreas on 14.12.16.
//  Copyright © 2016 ETH Zurich - COSS. All rights reserved.
//

import Foundation

class GeneralSensorConfiguration {
    public private(set) var sensorID : UInt64 //getter: public, setter: private
    public private(set) var sensorName : String
    public private(set) var parameterDef : [(name: String, type: String)]
    
    init(sensorID : UInt64, sensorName : String, parameterDef : [(name: String, type: String)]) {
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
