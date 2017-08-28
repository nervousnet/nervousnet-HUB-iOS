//
//  VM.swift
//  nervousnet-HUB-iOS
//
//  Created by Enz  Andreas on 21.12.16.
//  Copyright © 2016 ETH Zurich - COSS. All rights reserved.
//

import Foundation
import Parse

public class VM {
    
    //uuid: used to anonymously differentiate user data sent to the global DB
    public private(set) var uuid : UUID?
    
    //entity to manage configurations
    private let configManager : iConfigurationManager
    
    //entity to manage the local db
    private let dbManager = DBManager.sharedInstance
    
    //map of sensors
    private var sensorMap = [Int64 : BaseSensor]()
    
    //TODO: list of registered Sensors (to be used in init)
    //list of implemented hardware sensors
    public var hardwareSensorList : [Int64 : String] = [1000 : "Accelerometer",
                                                        1001 : "Gyroscope",
                                                        1003 : "Location",
                                                        1002 : "Magnetometer"]
    
    public static let sharedInstance = VM()
    
    public var sensorNameToID : [String : Int64] {
        get {
            return configManager.sensorNameToID
        }
    }
    
    
    
    /* Start the sensors according to a given configuration and connect to DB,
       let the VM listen to Sensor state changes */
    private init() {
        configManager = ConfigurationManager()
     
        for config in configManager.getAllConfigurations() {
            //TODO: if possible provide type BasicSensorConfiguration directly instead of forcing
            do {
                _ = try self.initSensor(withConfig: config as! BasicSensorConfiguration)
            } catch _ {
                log.error("Initialization error")
            }
        }
        
        if configManager.getNervousnetState() == VMConstants.STATE_RUNNING {
            startAllSensors()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNNEvent(_:)), name: NNEvent.name, object: nil)
        
    
    }

    
    public func run() {
        //TODO: could do more setup based on nervous state:
        // - starting sensors depending on state
        // - starting db store task
        // CAREFUL: this is needed because otherwies layz eval would instantiate VM at the wrong time
        log.info("VM is a go!")
    }
    
    
    //////////////////////////////
    /// SENSOR CONTROL METHODS ///
    /// ====================== ///
    
    /* Initialize sensor with a given configuration, dynamically create the correct sensor wrapper class given by the 'wrapperName'
     * in the config 
     */
    private func initSensor(withConfig config : BasicSensorConfiguration) throws -> BaseSensor {
        if let sensor = sensorMap[config.sensorID] {
            _ = sensor.stop()
        } //MARK: if the sensor existed already, why proceed here?
        
        do {
            try dbManager.createTableIfNotExists(config: config)
        } catch DBManager.DBError.DBConnectionError {
            log.error("Unable to create DB table since there seems to be no DB connection")
            throw VMErrors.DBConnectionError
        }
        
        guard config.samplingrate >= 0 else {   //samplingrate is guaranteed to be positive for the rest of this function
            log.error("Negative sampling rate, sensor not initialized" + config.sensorName)
            throw VMErrors.SensorIsOffException
        }
        

        
        //Switch case is a bit unnecessary, but shortens the string value check syntax
        switch(config.sensorName) {
        case "Accelerometer", "Gyroscope", "Magnetometer":
            let newSensor : BaseSensor = CoreMotionSensor(conf: config)
            sensorMap[config.sensorID] = newSensor //if sensorID already in the list we overwrite the sensor object
            return newSensor
        default:
            if #available(iOS 10.0, *), config.sensorName == "GPS" {
                let newSensor : BaseSensor = CoreLocationSensor(conf: config)
                sensorMap[config.sensorID] = newSensor //if sensorID already in the list we overwrite the sensor object
                return newSensor
            }
            
            throw VMErrors.InstantiationException
        }
        
        
        /* FIXME: implement better sensor creation with less hardcoding? see below as a starting point
        //create the correct Sensor dynamically according to its name
        //source: http://thecache.trov.com/swift-2-create-an-instance-of-a-class-from-a-string-by-calling-a-custom-initializer/
        
        if let sensorType = NSClassFromString(config.getWrapperName()) as? BaseSensor.Type {
            let newSensor = sensorType.init(conf:  config)
            sensorMap[config.sensorID] = newSensor //if sensorID already in the list we overwrite the sensor object
            
            return newSensor
        } else {
            log.error("unable to infer sensor type from given wrapper name: \(config.getWrapperName())")
            throw VMErrors.InstantiationException
        }
        */
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
            stopSensor(withID: sensorID)
        }
    }
    
    
    
    public func stopSensor(withID id : Int64) {
        if let sensor = sensorMap[id] {
            _ = sensor.stop()
        }
    }
    
    
    ////////////////////////
    /// SENSOR DB ACCESS ///
    /// ================ ///
    
    // WRITE
    
    public func store(reading : SensorReading) {
        dbManager.store(reading: reading)
    }
    
    
    public func store(readingList : [SensorReading]) {
        dbManager.store(readings: readingList)
    }
    
    
    
    
    // READ
    
    /**
     * Returns latest reading that has been stored since starting the application.
     */
    public func getLatestReading(sensorID : Int64) throws -> SensorReading {
        return try dbManager.getLatestReading(sensorID: sensorID) //TODO: error handling here?
    }
    
    
    public func getReadings(sensorID : Int64) throws -> [SensorReading] {
        return try dbManager.getReadings(with : configManager.getConfiguration(sensorID: sensorID)) //TODO: error handling here?
    }
    
    
    public func getReadings(sensorID : Int64, start : Int64, end : Int64) throws -> [SensorReading] {
        return try dbManager.getReadings(with: configManager.getConfiguration(sensorID: sensorID),
                                         startTimestamp: start,
                                         endTimestamp: end)
         //TODO: error handling here?
    }
    
    
    //TODO: getReading and getReadings with a callback function
    
    
    //Save Cached Data to remote Server
    func cacheToServer() -> Void {
        
        for sensor in configManager.getAllConfigurations() {
            let query = PFQuery(className:sensor.sensorName)
            query.fromPin(withName: sensor.sensorName)
            query.findObjectsInBackground().continue({
                (task: BFTask!) -> AnyObject! in
                let scores = task.result!
                for score in scores {
                    (score as AnyObject).saveInBackground().continue(successBlock: {
                        (task: BFTask!) -> AnyObject! in
                        log.debug("IT WORKED")
                        return (score as AnyObject).unpinInBackground()
                    })
                }
                return task
            })

        }
    }
    
    func cacheToServer(sensorName : String) -> Void {
        
        let query = PFQuery(className: sensorName)
        query.fromPin(withName: sensorName)
        query.findObjectsInBackground().continue({
            (task: BFTask!) -> AnyObject! in
            let scores = task.result!
            for score in scores {
                (score as AnyObject).saveInBackground().continue(successBlock: {
                    (task: BFTask!) -> AnyObject! in
                    return (score as AnyObject).unpinInBackground()
                })
            }
            return task
        })
            
        
    }

    
    
    
    
    
    // DB MANAGEMENT
    
    public func deleteTableIfExists(sensorID : Int64) throws {
        try dbManager.deleteTableIfExists(config: configManager.getConfiguration(sensorID: sensorID))
    }
    
    
    public func createTableIfNotExists(sensorID : Int64) throws {
        try dbManager.createTableIfNotExists(config: configManager.getConfiguration(sensorID: sensorID))
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
            let nervousState = configManager.getNervousnetState()
            if state != oldState {
                try configManager.setSensorState(sensorID: sensorID, state: state)                                  //update state
                if nervousState != VMConstants.STATE_PAUSED { //if not paused restart sensors with new settings
                    if state == VMConstants.SENSOR_STATE_AVAILABLE_BUT_OFF { stopSensor(withID: sensorID) }             //turn off
                    else if oldState == VMConstants.SENSOR_STATE_AVAILABLE_BUT_OFF { startSensor(withID: sensorID) }    //turn on
                    else { //frequency change, restart sensor with new ID
                        stopSensor(withID: sensorID)
                        startSensor(withID: sensorID)
                    }
                }
                
                if state == VMConstants.SENSOR_STATE_AVAILABLE_BUT_OFF {
                    dbManager.removeLatestReading(for : sensorID)
                }
            }
        } catch _ {
            log.error("Sensor state could not be updated properly")
        }
    }
    
    

    public func setSensorFrequency(for sensor: String, to state: Int) throws {
        if let id = sensorNameToID[sensor] {
            updateSensorState(sensorID: id, state: state)
        } else {
            throw VMErrors.UnkownSensorException
        }
    }
    
    

    public func getFrequencySettings (for sensor : String) throws -> [Int64] {
        if let id = sensorNameToID[sensor] {
            let config = try configManager.getConfiguration(sensorID: id) as! BasicSensorConfiguration
            return config.samplingrates
        } else {
            throw VMErrors.UnkownSensorException
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
                    
                    dbManager.stopScheduledTask()
                    
                    
                    let event = NNEvent(eventType: VMConstants.EVENT_NERVOUSNET_STATE_UPDATED)
                    
                    NotificationCenter.default.post(name: NNEvent.name, object: nil, userInfo: event.info)
                
                case VMConstants.EVENT_START_NERVOUSNET_REQUEST:
                    /* start all sensors */
                    storeNervousnetState(state: VMConstants.STATE_RUNNING)
                    
                    dbManager.startScheduledTask()
                    
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
        case SensorIsOffException       //
        case DBConnectionError          // dbManager was unable to connect to the DB
        case InstantiationException     // unable to create class from string
        case UnkownSensorException
    }
    
    
    
    
}
