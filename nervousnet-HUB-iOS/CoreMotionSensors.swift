//
//  CoreMotionSensors.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 07.03.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import Foundation
import CoreMotion

class CoreMotionSensor : BaseSensor {
    
    //Move these to the VM as singletons
    let motionManager = CMMotionManager()
    let operationQueue = OperationQueue.init()
    
    required public init(conf: BasicSensorConfiguration) {
        super.init(conf: conf)
        
        motionManager.deviceMotionUpdateInterval = TimeInterval(super.configuration.samplingrate)

        motionManager.startAccelerometerUpdates(to: operationQueue, withHandler: accHandler)
    }

    func accHandler (data : CMAccelerometerData?, error: Error?) -> Void {
        print(data.debugDescription)
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
//        print(data.debugDescription + "was actually measured")
//    }
//    
//    
//    
//}
