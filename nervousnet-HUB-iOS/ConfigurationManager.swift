//
//  ConfigurationManager.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 11.01.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import Foundation

public class ConfigurationManager : iConfigurationManager {
    
    func getAllConfigurations() -> [GeneralSensorConfiguration] {
        return [GeneralSensorConfiguration]()
    }
    
    func getConfiguration(sensorID: Int64) throws -> GeneralSensorConfiguration {
        return GeneralSensorConfiguration(sensorID: 5, sensorName: "a", parameterNames: ["hi"], parameterTypes: ["Double"])
    }
    
    func getNervousnetState() -> Int {
        return Int()
    }
    
    func getSensorIDs() -> [Int64] {
        return [Int64]()
    }
    
    func getSensorState(sensorID: Int64) throws -> Int {
        return Int()
    }
    
    func setNervousnetState(state: Int) {
    }
    
    func setSensorState(sensorID: Int64, state: Int) throws {
    }
    
}
