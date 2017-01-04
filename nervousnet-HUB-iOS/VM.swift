//
//  VM.swift
//  nervousnet-HUB-iOS
//
//  Created by Enz  Andreas on 21.12.16.
//  Copyright © 2016 ETH Zurich - COSS. All rights reserved.
//

import Foundation

public class VM {
    
    //uuid: used to anonymously differentiate user data sent to the global DB
    public private(set) var uuid : UUID?
    
    //entity to manage configurations
    private let configManager : iConfigurationManager
    
    //entity to manage the local db
    private let dbManager = DBManager.sharedInstance
    
    //map of sensors
    private var sensorMap = [Int64 : BaseSensor]()
    
    
    
    
    public init() {
        configManager = ConfigurationManager()
        
     
        for config in configManager.getAllConfigurations() {
            //TODO: if possible provide type BasicSensorConfiguration directly instead of forcing
            do {
                try self.initSensor(withConfig: config as! BasicSensorConfiguration)
            } catch _ {
                log.error("Initialization error")
            }
        }
        
        if configManager.getNervousState() == VMConstants.NervousState.RUNNING {
            startAllSensors()
        }
        
        //TODO: register eventbus
    }
    
    
    
    
    //////////////////////////////
    /// SENSOR CONTROL METHODS ///
    /// ====================== ///
    
    private func initSensor(withConfig config : BasicSensorConfiguration) throws -> BaseSensor {
        if let sensor = sensorMap[config.sensorID] {
            sensor.stop()
        } //MARK: if the sensor existed already, why proceed here?
        
        guard config.samplingrate >= 0 else {
            log.error("Negative sampling rate, sensor not initialized")
            throw VMErrors.SensorIsOffException
        }
        
        //samplingrate is guaranteed to be positive from now on
        
        
        let newSensor = BaseSensor() //TODO: create this dynamically correct
        sensorMap[config.sensorID] = newSensor //if sensorID already in the list we overwrite the sensor object
        
        dbManager.createTableIfNotExists(config: config)
        

        
        return newSensor
    }
    
    
    public func registerSensor(withConfig config : GeneralSensorConfiguration) {/* TODO: no impl in android */ }
    
    
    public func startAllSensors() {
        for sensorID in configManager.getSensorIDs() {
            startSensor(withID: sensorID)
        }
    }
    
    
    public func startSensor(withID id : Int64) {
        if let sensor = sensorMap[id] {
            sensor.start()
        } else {
            do {
                let newSensor = try initSensor(
                    withConfig: configManager.getConfiguration(forID: id) as! BasicSensorConfiguration)
                newSensor.start()
            } catch VMErrors.SensorIsOffException {
                log.error("sensor unexpectedly switched off")
            } catch _ {
                log.error("Unkown error occured")
            }

        }
    }
    
    
    public func stopAllSensors() {
        for sensorID in configManager.getSensorIDs() {
            startSensor(withID: sensorID)
        }
    }
    
    
    public func stopSensor(withID id : Int64) {
        if let sensor = sensorMap[id] {
            sensor.stop()
        }
    }
    
    
    ////////////////////////
    /// SENSOR DB ACCESS ///
    /// ================ ///
    
    // WRITE
    
    public func store(reading : SensorReading) {
        //TODO
    }
    
    
    public func store(readingList : [SensorReading]) {
        //TODO
    }
    
    
    
    // READ
    
    private func getLatestReading(sensorID : Int64) {
        //TODO
    }
    
    
    private func getReading(sensorID : Int64) {
        //TODO
    }
    
    
    private func getReadings(sensorID : Int64, start : UInt64, end : UInt64) {
        //TODO
    }
    
    
    
    // DB MANAGEMENT
    
    public func deleteTableIfExists(sensorID : Int64) {
        //TODO
    }
    
    
    public func deleteTableIfNotExists(sensorID : Int64) {
        //TODO
    }
    
    
    public func createTableIfNotExists(sensorID : Int64) {
        //TODO
    }
    
    
    public func deleteAllDatabases() {
        //TODO
    }
    
    
    
    //////////////////////
    /// STATE HANDLING ///
    /// ============== ///
    //MARK: why does this state stuff exist??
    public func storeNervousnetState() { }
    
    public func getNervousnetState() { }
    
    public func updateSensorState() { }

    public func storeSensorState() { }
    
    
    
    
    ////////////////////
    /// UUID METHODS ///
    /// ============ ///
    
    //TODO: make this synchronized. how (and why)??
    // http://stackoverflow.com/questions/24045895/what-is-the-swift-equivalent-to-objective-cs-synchronized

    public func newUUID() {
        uuid = UUID()
    }
    
    
    
    /////////////////
    /// VM ERRORS ///
    /// ========= ///
    
    private enum VMErrors : Error {
        case SensorIsOffException
    }
    
    
    
    
}
