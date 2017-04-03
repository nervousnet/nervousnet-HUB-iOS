//
//  SensorReading.swift
//  nervousnet-HUB-iOS
//
//  Created by Enz  Andreas on 15.12.16.
//  Copyright © 2016 ETH Zurich - COSS. All rights reserved.
//

import Foundation

public class SensorReading {
    
    public let timestampEpoch : Int64 //get and set public
    
    public let sensorConfig : GeneralSensorConfiguration

    public private(set) var values = [String : Any?]()
    
    public var parameterNameToType : [String : String] {
        get {
            return sensorConfig.parameterNameToType
        }
    }


    
    //initializer with values known
    /**
     * Return a new SensorReading object, representing a measurement at a certain time
     * configured according to 'config'
     * - Throws: if the 'values' list count does not match config.paramDim
     */
    public init (config: GeneralSensorConfiguration,
                 values: [Any],
                 timestamp: Int64) throws {
        
        self.sensorConfig = config
        self.timestampEpoch = timestamp
        
        //TODO: maybe the following can be improved by a 'value builder' in sensorconfig for example
        // to make sure correct value for specific parameter (and not e.g. switched the values for param )
        guard values.count == config.parameterDim else { // wrong value count provided, throw error
            throw SRError.InvalidValueCount("size of values needs to match config parameter dimension")
        }
        
        //construct map with appropriate values
        var i = 0
        for idx in config.parameterNameToType.keys {
            self.values[idx] = values[i]
            i += 1
        }
    }
    
    
    //initializer with unknown values
    public init (config: GeneralSensorConfiguration,
                 timestamp: Int64) {
        
        self.sensorConfig = config
        self.timestampEpoch = timestamp

        
        var i = 0
        for idx in config.parameterNameToType.keys {
            self.values[idx] = nil
            i += 1
        }
    }
    
    //setter and getter for values depending on paramName
    
    public func setValue(paramName: String, value : Any) -> Bool {
        //overwrites value priviously in the map under 'paramName'
        //if the paramName is actually in the sensorConfig
        if let _ = sensorConfig.parameterNameToType.index(forKey: paramName) {
            self.values.updateValue(values, forKey: paramName)
            return true
        }
        return false
    }
    
    public func getValue(paramName: String) -> Any? {
        return values[paramName] ?? nil
    }

    
    enum SRError : Error {
        case InvalidValueCount(String)
    }
}
