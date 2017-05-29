//
//  BasicSensorConfiguration.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 11.01.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import Foundation

/* this the specification of the most basic Form sensorConfigurations might take in the real world*/
public class BasicSensorConfiguration : GeneralSensorConfiguration {
    
    //I am not quite sure what the first one is for. The Array takes a number of samplingrates, which can be selected by chosing a state. More details in the constants.
    public private(set) var samplingrate : Int64
    public private(set) var samplingrates : [Int64]
    public private(set) var state : Int
    
    
    //init and set appropriate state
    init(sensorID : Int64, sensorName : String, parameterDef : [String : String], samplingrates : [Int64], state: Int) {
        self.samplingrate = 0
        self.state = state
        self.samplingrates = samplingrates
        super.init(sensorID: sensorID, sensorName: sensorName, parameterDef: parameterDef)
        self.setState(state: state)
        
    }
    
    
    //set at which rate the sensor will aggregate data
    func setState(state : Int){
        
        switch state{
            
        case VMConstants.SENSOR_STATE_AVAILABLE_BUT_OFF:
            self.samplingrate = -1
            self.state = state
        case VMConstants.SENSOR_STATE_AVAILABLE_DELAY_LOW:
            self.samplingrate = samplingrates[0]
            self.state = state
        case VMConstants.SENSOR_STATE_AVAILABLE_DELAY_MED:
            self.samplingrate = samplingrates[1]
            self.state = state
        case VMConstants.SENSOR_STATE_AVAILABLE_DELAY_HIGH:
            self.samplingrate = samplingrates[2]
            self.state = state
        default:
            self.state = VMConstants.SENSOR_STATE_AVAILABLE_BUT_OFF
            self.samplingrate = -1
            
        }
    }
    
    //TODO
    public func getWrapperName ()  -> String {
        return "dummyString"
    }
    
    //converts the current configuration to a string for use outside swift
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
