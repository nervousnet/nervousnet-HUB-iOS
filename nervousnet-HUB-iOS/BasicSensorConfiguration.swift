//
//  BasicSensorConfiguration.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 11.01.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import Foundation

public class BasicSensorConfiguration : GeneralSensorConfiguration {
    
    public private(set) var samplingrate : Int64
    public private(set) var samplingrates : [Int64]
    public private(set) var state : Int
    
    
    
    init(sensorID : Int64, sensorName : String, parameterDef : [String : String], samplingrates : [Int64], state: Int) {
        self.samplingrate = 0
        self.state = state
        self.samplingrates = samplingrates
        super.init(sensorID: sensorID, sensorName: sensorName, parameterDef: parameterDef)
        self.setState(state: state)
        
    }
    
    
    
    func setState(state : Int){
        
        switch state{
            
        case VMConstants.SENSOR_STATE_AVAILABLE_BUT_OFF:
            self.samplingrate = -1
            
        case VMConstants.SENSOR_STATE_AVAILABLE_DELAY_LOW:
            self.samplingrate = samplingrates[0]
            
        case VMConstants.SENSOR_STATE_AVAILABLE_DELAY_MED:
            self.samplingrate = samplingrates[1]
            
        case VMConstants.SENSOR_STATE_AVAILABLE_DELAY_HIGH:
            self.samplingrate = samplingrates[2]
            
        default:
            self.samplingrate = -1
            
        }
    }
    
    public func getWrapperName ()  -> String {
        return "dummyString"
    }
    
    public override func toString() -> String{
        var returnString : String = "ConfigurationClass{"
            returnString +=         ("sensorName=" + self.sensorName)
            returnString +=         ("\\" + ", parametersNames=")
            returnString +=         (", parametersNames=" + self.parameterNameToType.keys.elements.joined(separator: ", "))
            returnString +=         (", parametersTypes=" + self.parameterNameToType.values.elements.joined(separator: ", "))
            returnString +=         (", samplingPeriod="  + String(self.samplingrate))
            returnString +=         "}"
       
        return returnString
    }

}
