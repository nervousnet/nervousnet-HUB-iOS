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
    func getNervousState() -> VMConstants.NervousState
    func getSensorIDs() -> [Int64]
}


class ConfigurationManager : iConfigurationManager {
    
    public func getAllConfigurations() -> [GeneralSensorConfiguration] { return [] }
    
    public func getNervousState() -> VMConstants.NervousState { return .RUNNING }
    
    internal func getSensorIDs() -> [Int64] { return [] }
}



class BaseSensor {
    //parent class to all sensor implementations
}





class BasicSensorConfiguration : GeneralSensorConfiguration {
    // more configuration classes
    // MARK: Could we combine configuration classes??
}
