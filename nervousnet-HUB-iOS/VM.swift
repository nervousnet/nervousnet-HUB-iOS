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
    
    
    
    /* Start the sensors according to a given configuration and connect to DB,
       let the VM listen to Sensor state changes */
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
        
        if configManager.getNervousnetState() == VMConstants.STATE_RUNNING {
            startAllSensors()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNNEvent(_:)), name: NNEvent.name, object: nil)
        
    
    }
    
    
    
    
    //////////////////////////////
    /// SENSOR CONTROL METHODS ///
    /// ====================== ///
    
    /* Initialize sensor with a given configuration */
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
    
    
    /* start sensor. skip sensors we cannot start and show an error */
    public func startSensor(withID id : Int64) {
        if let sensor = sensorMap[id] {
            sensor.start()
        } else {
            do {
                let newSensor = try initSensor(
                    withConfig: configManager.getConfiguration(sensorID: id) as! BasicSensorConfiguration)
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

    public func storeNervousnetState(state : Int) {
        configManager.setNervousnetState(state: state)
    }
    
    
    
    public func getNervousState() -> Int {
        return configManager.getNervousnetState()
    }
    
    
    
    public func getSensorState(sensorID : Int64) -> Int {
        do {
            return try configManager.getSensorState(sensorID: sensorID)
        } catch _ {
            log.info("Unable to retrieve sensor state for \(sensorID), pretending it is off but available")
            return VMConstants.SENSOR_STATE_AVAILABLE_BUT_OFF
        }
        
    }
    
    
    
    public func updateSensorState(sensorID : Int64, state : Int) {
        
        do {
            let oldState = try configManager.getSensorState(sensorID: sensorID)
        
            if state != oldState {
                try configManager.setSensorState(sensorID: sensorID, state: state)                                  //update state
                if state == VMConstants.SENSOR_STATE_AVAILABLE_BUT_OFF { stopSensor(withID: sensorID) }             //turn off
                else if oldState == VMConstants.SENSOR_STATE_AVAILABLE_BUT_OFF { startSensor(withID: sensorID) }    //turn on
            }
        } catch _ {
            log.error("Sensor state could not be updated properly")
        }
    }
    
    
    
    
    /* Handle Sensor Events from the Notification Center (eventBus in android) 
     * Basically we switch Sensors on and off or update their State */
    
    @objc private func onNNEvent(_ notification : NSNotification) {
        if let info = notification.userInfo {
            if let eventType = info[NNEvent.InfoLabel.EVENT_TYPE] as? Int {
                
                switch(eventType) {
                case VMConstants.EVENT_CHANGE_SENSOR_STATE_REQUEST:
                    /* update specific sensor */
                    if let id = info[NNEvent.InfoLabel.SENSORID] as? Int64, let state = info[NNEvent.InfoLabel.STATE] as? Int{
                        
                        updateSensorState(sensorID: id, state: state)
                        
                        let event = NNEvent(eventType: VMConstants.EVENT_SENSOR_STATE_UPDATED)
                        NotificationCenter.default.post(name: NNEvent.name, object: nil, userInfo: event.info)
                    } else {
                        log.error("unable to unpack NNEvent userInfo into expected variables (sensorID, state)")
                    }
                    
                case VMConstants.EVENT_CHANGE_ALL_SENSORS_STATE_REQUEST:
                    /* update state of all sensors */
                    if let state = info[NNEvent.InfoLabel.STATE] as? Int{
                        for sensorID in configManager.getSensorIDs() {
                            updateSensorState(sensorID: sensorID, state: state)
                        }
                        
                        let event = NNEvent(eventType: VMConstants.EVENT_SENSOR_STATE_UPDATED)
                        
                        NotificationCenter.default.post(name: NNEvent.name, object: nil, userInfo: event.info)
                    } else {
                        log.error("unable to unpack NNEvent userInfo into expected variables (state)")
                    }
                    
                    
                case VMConstants.EVENT_PAUSE_NERVOUSNET_REQUEST:
                    /* stop all sensors */
                    storeNervousnetState(state: VMConstants.STATE_PAUSED)
                    stopAllSensors()
                    
                    let event = NNEvent(eventType: VMConstants.EVENT_NERVOUSNET_STATE_UPDATED)
                    
                    NotificationCenter.default.post(name: NNEvent.name, object: nil, userInfo: event.info)
                
                case VMConstants.EVENT_START_NERVOUSNET_REQUEST:
                    /* start all sensors */
                    storeNervousnetState(state: VMConstants.STATE_RUNNING)
                    startAllSensors()
                    
                    let event = NNEvent(eventType: VMConstants.EVENT_NERVOUSNET_STATE_UPDATED)
                    
                    NotificationCenter.default.post(name: NNEvent.name, object: nil, userInfo: event.info)
                    
                default:
                    return
                }
            } else {
                log.error("NNEvent info does not contain an event type")
                //this should not happen since NNEvent is always created with an eventType
            }
        } else {
            log.error("NNEvent does not contain any user info. We cannot handle this properly.")
        }
    }
    
    
    
    
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
