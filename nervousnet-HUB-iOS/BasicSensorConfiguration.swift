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
    

    
    init(sensorID : Int64, sensorName : String, parameterNames : [String], parameterTypes: [String], samplingrate : Int64, samplingrates : [Int64], state: Int) {
        super.init(sensorID: sensorID, sensorName: sensorName, parameterNames: parameterNames, parameterTypes: parameterTypes)
        self.setState(state: state)
    }
    
    
    
    func setState(state : Int){
        self.state = state;
        
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
    
   
    public override func toString() -> String{
        let returnString : String =
            "ConfigurationClass{" +
                "sensorName=" + self.sensorName +
                "\\" +
                ", parametersNames=" + self.parameterNames.joined(separator: ", ") +
                ", parametersTypes=" + self.parameterTypes.joined(separator: ", ") +
                ", samplingPeriod="  + self.samplingrate +
            "}"
        return returnString
    }

}
