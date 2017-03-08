//
//  SensorReading.swift
//  nervousnet-HUB-iOS
//
//  Created by Enz  Andreas on 15.12.16.
//  Copyright © 2016 ETH Zurich - COSS. All rights reserved.
//

import Foundation

public class SensorReading {
    
    public var sensorID : Int64? // get and set public
    public private(set) var sensorName : String? //get public, set private
    public var timestampEpoch : Int64? //get and set public
    private var pNames : [String]? // private field to access for computed variable parameterNames
    public var parameterNames : [String]? {//get and set public
        get {
            return pNames
        }
        set(parameterNames){
            self.pNames = parameterNames
            if let list = parameterNames {
                if values == nil ||
                list.count != values?.count {
                
                values = [Any?](repeating: nil, count: list.count)
                }
            }
            else {
                values = nil
            }
        }
    }
    
    public var values : [Any?]?
    
    
    
    
    
    public init() {}

    
    
    public init(sensorID : Int64,
                sensorName : String,
                parameterNames : [String]) {
        self.sensorID = sensorID
        self.sensorName = sensorName
        self.parameterNames = parameterNames
        
        
        //not very nice way to create fixed size array of generic type
        //but the best i found in swift so far
        self.values = [Any?](repeating: nil, count: parameterNames.count)
    }
    
    
    //Lewin: added this because it makes sense to have in order to push sensorrreadings in one line
    
    public init (sensorID : Int64,
                 sensorName : String,
                 parameterNames : [String],
                 values: [Any]){
        
        self.sensorID = sensorID
        self.sensorName = sensorName
        self.parameterNames = parameterNames

        if (values.count == parameterNames.count){
            self.values = values
        }
        else {
            self.values = [Any?](repeating: nil, count: parameterNames.count)
        }
    
    }
    
    
    
    public func setValue(paramName: String, value : Any) -> Bool {
        
        // check if we can retrieve the index of the parameter Name
        guard let names = self.parameterNames ,
            let index = names.index(of: paramName) else {
            return false
        }

        //check if the index is not out of bounds
        guard let c = values?.count, c > index else {
            return false
        }
        
        //if values == nil this does nothing
        //but we already tested 'values' for nil in previous guard
        //MARK: could be a problem if we are doing multithreading
        values?[index] = value
        
        return true
    }
}
