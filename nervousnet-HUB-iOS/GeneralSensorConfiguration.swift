//
//  GeneralSensorConfiguration.swift
//  nervousnet-HUB-iOS
//
//  Created by Enz  Andreas on 14.12.16.
//  Copyright © 2016 ETH Zurich - COSS. All rights reserved.
//

import Foundation

public class GeneralSensorConfiguration {
    
//    // Fix the possible config types in an enmum
//    public enum sType {
//        case int_t
//        case double_t
//        case string_t
//    }
    
    public private(set) var sensorID : Int64 //getter: public, setter: private
    public private(set) var sensorName : String
    public private(set) var parameterNameToType : [String : String] //map: name -> type (TODO: type as enum)
    
    init(sensorID : Int64, sensorName : String, parameterDef nameToType : [String : String]) {
        self.sensorID = sensorID
        self.sensorName = sensorName
        self.parameterNameToType = nameToType
    }
    
    public var parameterDim : Int {
        get {
            return parameterNameToType.count
        }
    }
    
    public func toString() -> String{
        let returnString : String =
            "ConfigurationClass{" +
                "sensorName=" + self.sensorName +
                "\\" +
                ", parametersNames=" + self.parameterNameToType.keys.elements.joined(separator: ", ") +
                ", parametersTypes=" + self.parameterNameToType.values.elements.joined(separator: ", ") +
        "}"
        return returnString
    }

    
}
