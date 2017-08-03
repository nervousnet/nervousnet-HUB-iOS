//
//  CoreMotionSensors.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 07.03.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import Foundation
import CoreMotion
import UIKit

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
        
        let timestamp = getTimeStampMilliseconds()
        
        if data != nil {
            let x = data!.acceleration.x
            let y = data!.acceleration.y
            let z = data!.acceleration.z
            
            do {
                let sensorReading =  try SensorReading(config: super.configuration, values: [x, y, z], timestamp: timestamp)
                super.push(reading: sensorReading)
                if let navController  = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
                    if let visualizer = navController.visibleViewController as? SensorStatisticsViewController{
                        DispatchQueue.main.async {
                            visualizer.updateGraph(sensorReading: sensorReading)
                        }
                    }
                }

            } catch _ {
                log.error("This should not happen. 'values' count does not match param dimension. Pushing empty 'SensorReading'")
                super.push(reading: SensorReading(config: super.configuration, timestamp: timestamp))
            }
        }
        else {
            super.push(reading: SensorReading(config: super.configuration, timestamp: timestamp))
        }
    }
    
    func gyrHandler (data : CMGyroData?, error: Error?) -> Void {

        let timestamp = getTimeStampMilliseconds()
        
        if data != nil {
            let x = data!.rotationRate.x
            let y = data!.rotationRate.y
            let z = data!.rotationRate.z
            //Mark
            do {
                let sensorReading =  try SensorReading(config: super.configuration, values: [x, y, z], timestamp: timestamp)
                super.push(reading: sensorReading)
                if let navController  = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
                    if let visualizer = navController.visibleViewController as? SensorStatisticsViewController{
                        DispatchQueue.main.async {
                            visualizer.updateGraph(sensorReading: sensorReading)
                        }
                    }
                }
                
            } catch _ {
                log.error("This should not happen. 'values' count does not match param dimension. Pushing empty 'SensorReading'")
                super.push(reading: SensorReading(config: super.configuration, timestamp: timestamp))
            }
        }
            
            
            
        else {
            super.push(reading: SensorReading(config: super.configuration, timestamp: timestamp))
        }
    }
    
    func magHandler (data : CMMagnetometerData?, error: Error?) -> Void {

        let timestamp = getTimeStampMilliseconds()
        
        if data != nil {
            let x = data!.magneticField.x
            let y = data!.magneticField.y
            let z = data!.magneticField.z
            //Mark
            do {
                let sensorReading =  try SensorReading(config: super.configuration, values: [x, y, z], timestamp: timestamp)
                super.push(reading: sensorReading)
                if let navController  = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
                    if let visualizer = navController.visibleViewController as? SensorStatisticsViewController{
                        DispatchQueue.main.async {
                            visualizer.updateGraph(sensorReading: sensorReading)
                        }
                    }
                }
                
            } catch _ {
                log.error("This should not happen. 'values' count does not match param dimension. Pushing empty 'SensorReading'")
                super.push(reading: SensorReading(config: super.configuration, timestamp: timestamp))
            }
        }
        else {
            super.push(reading: SensorReading(config: super.configuration, timestamp: timestamp))
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
