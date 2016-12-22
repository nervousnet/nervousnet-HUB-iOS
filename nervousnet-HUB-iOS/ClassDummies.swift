//
//  ClassDummies.swift
//  nervousnet-HUB-iOS
//
//  Created by Enz  Andreas on 21.12.16.
//  Copyright © 2016 ETH Zurich - COSS. All rights reserved.
//

import Foundation



protocol iConfigurationManager {
    //interfrace that defines management of (sensor?) configurations
    
    func getAllConfigurations() -> [GeneralSensorConfiguration]
    func getConfiguration(forID id : Int64) -> GeneralSensorConfiguration?
    func getNervousState() -> VMConstants.NervousState
    func getSensorIDs() -> [Int64]
}


class ConfigurationManager : iConfigurationManager {
    
    public func getAllConfigurations() -> [GeneralSensorConfiguration] { return [] }
    
    public func getConfiguration(forID id : Int64) -> GeneralSensorConfiguration? { return nil }

    public func getNervousState() -> VMConstants.NervousState { return .RUNNING }
    
    internal func getSensorIDs() -> [Int64] { return [] }
}



class BaseSensor {
    //parent class to all sensor implementations
    
    func start() { }
    
    func stop() { }
}





class BasicSensorConfiguration : GeneralSensorConfiguration {
    // more configuration classes
    // MARK: Could we combine configuration classes??
    
    public private(set) var samplingrate : Int64
    
    init(sensorID : Int64, sensorName : String, parameterDef : [(name: String, type: sType)], samplingrate : Int64) {
        self.samplingrate = samplingrate
        super.init(sensorID: sensorID, sensorName: sensorName, parameterDef: parameterDef)
    }
    
    
}
