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

enum ConfigurationError: Error {
    case noSuchConfiguration(sensorID: Int64)
    case noStateSet(sensorID: Int64)
}

public class ConfigurationManager : iConfigurationManager {
    
    // This dictionary maps sensor ID into sensor's configuration.
    var configDict : [Int64:Any] //GeneralSensorConfiguration and BasicSensorConfiguration types only
    
        
     // Database manager for sensors' configuration storing and for application state storing.
    let stateDBManager : StateDBManager
    
    
    init () {
        
        configDict = [Int64:GeneralSensorConfiguration]()
        stateDBManager = StateDBManager.sharedInstance
        
    // Load default configuration from configuration file
        let loader : JSONConfigurationLoader = JSONConfigurationLoader()
        let confList : [BasicSensorConfiguration] = loader.load()
        
    // Check database if there are some stored states and overwrite default states from
    // the configuration file.
    for  conf in  confList {
        configDict[conf.sensorID] = conf
        do {
            let state : Int = try stateDBManager.getSensorState(sensorID: conf.sensorID)
            conf.setState(state: state)
        } catch{(error.localizedDescription)}
        
        stateDBManager.storeSensorState(sensorID: conf.sensorID , state: conf.state)
        }
    }
    
    
    func getAllConfigurations() -> [GeneralSensorConfiguration] {
        return Array(configDict.values) as! [GeneralSensorConfiguration]
    }
    
    func getConfiguration(sensorID: Int64) throws -> GeneralSensorConfiguration {
        
        if let returnConfiguration = configDict[sensorID]{
            return returnConfiguration as! GeneralSensorConfiguration
        }
        else{
            throw ConfigurationError.noSuchConfiguration(sensorID: sensorID)
        }
    }
    
    func getNervousnetState() -> Int {
        // if retrieving the state fails, what to do?
        do {
            return try stateDBManager.getNervousnetState()
        } catch _ {
            log.error("unable to retrieve the required state information")
            //TODO: should never happen? or, how to handle this? some default state?
            //or further propagate the error where instances retrieving the state can react properly
            fatalError()
        }
    }
    
    func getSensorIDs() -> [Int64] {
        return Array(configDict.keys)
    }
    
    func getSensorState(sensorID: Int64) throws -> Int {
        if let returnConfiguration = configDict[sensorID]{
            if let returnState = (returnConfiguration as? BasicSensorConfiguration)?.state {
                return returnState
            }
            else {throw ConfigurationError.noStateSet(sensorID: sensorID)}
        }
        else {throw ConfigurationError.noSuchConfiguration(sensorID: sensorID)}
    }
    
    func setNervousnetState(state: Int) {
        stateDBManager.storeNervousNetState(state: state)
    }
    
    func setSensorState(sensorID: Int64, state: Int) throws {
        if (configDict[sensorID] != nil){
            if (configDict[sensorID] as? BasicSensorConfiguration) != nil{
                stateDBManager.storeSensorState(sensorID: sensorID, state: state)
                (configDict[sensorID] as! BasicSensorConfiguration).setState(state: state)
            } else {
                throw ConfigurationError.noStateSet(sensorID: sensorID)
            }
        } else {
            throw ConfigurationError.noSuchConfiguration(sensorID: sensorID)
        }
    }
}
