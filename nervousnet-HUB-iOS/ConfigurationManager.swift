//
//  ConfigurationManager.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 11.01.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//


/**
 * ConfigurationManager is responsible for sensor collection state. It is responsible
 * for storing the state when some sensor collection configuration changes and restoring
 * the state when the application turns back on. This is necessary because application
 * crashes can appear. The idea is that the whole state is managed by ConfigurationManager.
 * <br/>
 * At the initialization of the ConfigurationManager, the manager goes through the
 * configuration file, that holds all sensors' configurations, and initializes sensors
 * according to the configurations. Then, it checks database and restores states of the
 * sensors that are stored before the app crashes or is shut down - default states form configuration file
 * are overwritten. If there is nothing to be restored, the states from configuration file persist.
 * <br/>
 * All configurations are hold in hashmap that map sensors' IDs into their configuration.
 * <br/>
 * TODO: To make this class a singleton. At the current development
 * stage, this is not the case yet.
 * TODO: There may be better solutions for database management.
 */



import Foundation

public class ConfigurationManager : iConfigurationManager {
    
    // This dictionary maps sensor ID into sensor's configuration.
    var configDict : [Int64:GeneralSensorConfiguration]
    
        
     // Database manager for sensors' configuration storing and for application state storing.
    let stateDBManager : StateDBManager
    
    
    init () {
        
        configDict = [Int64:GeneralSensorConfiguration]()
        stateDBManager = StateDBManager()
        
    // Load default configuration from configuration file
        let loader : JSONConfigurationLoader = JSONConfigurationLoader()
        let confList : [BasicSensorConfiguration] = loader.load()
        
    // Check database if there are some stored states and overwrite default states from
    // the configuration file.
    for  conf in  confList {
        configDict[conf.sensorID] = conf
        do {
            let state : Int = stateDBManager.getSensorState(sensorID: conf.sensorID)
            conf.setState(state: state)
        } catch{(error.localizedDescription)}
        
        stateDBManager.storeSensorState(sensorID: conf.sensorID , state: conf.state)
        }
    }
    
    
    func getAllConfigurations() -> [GeneralSensorConfiguration] {
        return Array(configDict.values)
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
