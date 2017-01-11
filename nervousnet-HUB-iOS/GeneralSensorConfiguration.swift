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
    public private(set) var parameterNames : [String]
    public private(set) var parameterTypes : [String] //Maybe change later, but needs operators properly working
    
    init(sensorID : Int64, sensorName : String, parameterNames : [String], parameterTypes : [String] ) {
        self.sensorID = sensorID
        self.sensorName = sensorName
        self.parameterNames = parameterNames
        self.parameterTypes = parameterTypes
    }
    
    public var parameterDim : Int {
        get {
            return parameterNames.count
        }
    }
    
    public func toString() -> String{
        let returnString : String =
            "ConfigurationClass{" +
                "sensorName=" + self.sensorName +
                "\\" +
                ", parametersNames=" + self.parameterNames.joined(separator: ", ") +
                ", parametersTypes=" + self.parameterTypes.joined(separator: ", ") +
        "}"
        return returnString
    }

    
}
