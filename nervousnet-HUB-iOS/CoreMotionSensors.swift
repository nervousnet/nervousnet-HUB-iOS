//
//  CoreMotionSensors.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 07.03.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import Foundation
import CoreMotion

//This is the raw data. Apple offers some processing to remove known sources of noise, which we should discuss

class CoreMotionSensor : BaseSensor {
    
    //TODO: Move these to the VM as singletons
    let motionManager = CMMotionManager()
    let operationQueue = OperationQueue.init()
    
    required public init(conf: BasicSensorConfiguration) {
        super.init(conf: conf)
        startListener()
    }

    func onConfChanged (){
        stopListener()
        startListener()
    }
    
    override func startListener() -> Bool {
        
        switch (configuration.sensorName.lowercased()){
        case "accelerometer" :
            motionManager.accelerometerUpdateInterval = TimeInterval(self.configuration.samplingrate)
            motionManager.startAccelerometerUpdates(to: operationQueue, withHandler: accHandler)
            return motionManager.isAccelerometerActive

        case "gyroscope":
            motionManager.gyroUpdateInterval = TimeInterval(self.configuration.samplingrate)
            motionManager.startGyroUpdates(to: operationQueue, withHandler: gyrHandler)
            return motionManager.isGyroActive

        case "magnetometer":
            motionManager.magnetometerUpdateInterval = TimeInterval(self.configuration.samplingrate)
            motionManager.startMagnetometerUpdates(to: operationQueue, withHandler: magHandler)
            return motionManager.isMagnetometerActive

        default:
            return false
        }

    }
    
    override func stopListener() -> Bool {
        
        switch (configuration.sensorName.lowercased()){
        case "accelerometer" :
            motionManager.stopAccelerometerUpdates()
            return !motionManager.isAccelerometerActive
        case "gyroscope":
            motionManager.stopGyroUpdates()
            return !motionManager.isGyroActive
        case "magnetometer":
            motionManager.stopMagnetometerUpdates()
            return !motionManager.isMagnetometerActive
        default:
            return false
        }

    }
    
    func accHandler (data : CMAccelerometerData?, error: Error?) -> Void {
        log.debug(data.debugDescription)
        
        let timestamp = getTimeStampMilliseconds()
        
        if data != nil {
            let x = data!.acceleration.x
            let y = data!.acceleration.y
            let z = data!.acceleration.z
            
            super.push(reading: SensorReading(sensorID: configuration.sensorID, sensorName: configuration.sensorName, parameterNames: ["accX", "accY", "accZ"], values: [x, y, z], timestamp: timestamp))
        }
        else {
            super.push(reading: SensorReading(sensorID: configuration.sensorID, sensorName: configuration.sensorName, parameterNames: ["accX", "accY", "accZ"]))
        }
    }
    
    func gyrHandler (data : CMGyroData?, error: Error?) -> Void {
        
        let timestamp = getTimeStampMilliseconds()
        
        if data != nil {
            super.push(reading: SensorReading(sensorID: configuration.sensorID, sensorName: configuration.sensorName, parameterNames: ["gyrX", "gyrY", "gyrZ"], values: [data!.rotationRate.x , data!.rotationRate.y , data!.rotationRate.z ], timestamp: timestamp))
        }
        else {
            super.push(reading: SensorReading(sensorID: configuration.sensorID, sensorName: configuration.sensorName, parameterNames: ["magX", "magY", "magZ"]))
        }
    }
    
    func magHandler (data : CMMagnetometerData?, error: Error?) -> Void {
        
        let timestamp = getTimeStampMilliseconds()
        
        
        if data != nil {
            super.push(reading: SensorReading(sensorID: configuration.sensorID, sensorName: configuration.sensorName, parameterNames: ["gyrX", "gyrY", "gyrZ"], values: [data!.magneticField.x, data!.magneticField.y , data!.magneticField ], timestamp: timestamp))
        }
        else {
            super.push(reading: SensorReading(sensorID: configuration.sensorID, sensorName: configuration.sensorName, parameterNames: ["magX", "magY", "magZ"]))
        }
    }

    private func getTimeStampMilliseconds() -> Int64 {
        return Int64((Date.timeIntervalBetween1970AndReferenceDate + Date.timeIntervalSinceReferenceDate) * 1000)
    }
    
    
}


//For easier Testing

//class CoreMotionSensor  {
//    
//    //Move these to the VM as singletons
//    let motionManager = CMMotionManager()
//    let operationQueue = OperationQueue.init()
//    
//    required public init(conf: Float) {
//        
//        //        motionManager.deviceMotionUpdateInterval = TimeInterval(super.configuration.samplingrate)
//        motionManager.accelerometerUpdateInterval = TimeInterval(conf)
//        
//        motionManager.startAccelerometerUpdates(to: operationQueue, withHandler: accHandler)
//    }
//    
//    func accHandler (data : CMAccelerometerData?, error: Error?) -> Void {
//        log.debug(data.debugDescription + "was actually measured")
//    }
//    
//    
//    
//}
