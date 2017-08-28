//
//  BaseSensor.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 11.01.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import Foundation
import Parse

public class BaseSensor : NSObject {
    
    let LOG_TAG = String(describing: type(of: BaseSensor.self))

    // Handlers
    private let dataBaseHandler : DBManager = DBManager.sharedInstance
  
    // Sensor configuration
    public var configuration : BasicSensorConfiguration
    
    // Just a shortcut of configuration above and maybe more intuitive
    // representation
    
    

    public private(set) var nextSampling : Int64 = 0
    public private(set) var nextPushing : Int64 = 0

    

    
    // Constructor of an abstract class for basic sensor reading.
 
    required public init (conf : BasicSensorConfiguration) {
        self.configuration = conf
        do {
            try self.dataBaseHandler.createTableIfNotExists(config: conf)
        }
        catch {(error.localizedDescription)}
        
    }
    
    
    // Method for accepting all new sensor readings from subclasses. It takes care of passing new
    // readings further for storing.
    
    func push(reading : SensorReading)  {
        if (reading.timestampEpoch >= nextSampling && configuration.samplingrate >= 0) {
            nextSampling = reading.timestampEpoch + self.configuration.samplingrate
            dataBaseHandler.store(reading: reading)
            
//            if (reading.timestampEpoch >= nextPushing) {
//                nextPushing = reading.timestampEpoch + 10*self.configuration.samplingrate
//                VM.sharedInstance.cacheToServer(sensorName: reading.sensorConfig.sensorName)
//            }
            
            //Stores Sensorreading to Server
            var serverData = PFObject(className: reading.sensorConfig.sensorName)
            for value in reading.values {
                serverData[value.key] = value.value
            }
            serverData["timestamp"] = reading.timestampEpoch
            serverData.saveEventually()
//            serverData.saveInBackground() {(succeeded, error) -> Void in
//                if succeeded {
//                } else {
//
//                    serverData.pinInBackground(withName: reading.sensorConfig.sensorName)
//                }
//            
//            }
        }
   
    }
   
    //Start sensor reading.
    
    func start () {
        stopListener()
        do {
            try self.dataBaseHandler.createTableIfNotExists(config: configuration)
        }
        catch {(error.localizedDescription)}

        startListener()
    }
    
     // Stop sensor reading
    
    func stop() -> Bool{
        return stopListener()
    }
    
     // Abstract method to register a sensor.
    func  startListener() -> Bool {
        return false
    }
    
    /**
     * Abstract method to unregister a sensor.
     */
    func stopListener() -> Bool {
        return false
    }
    
}
