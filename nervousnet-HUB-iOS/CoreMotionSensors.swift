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
    let operationQueue = OperationQueue.main //This needs to be different for actual update
    
    required public init(conf: BasicSensorConfiguration) {
        super.init(conf: conf)
        super.configuration = conf
        guard motionManager.isDeviceMotionAvailable else {
            fatalError("Device motion is not available")
        }
        
        motionManager.deviceMotionUpdateInterval = TimeInterval(super.configuration.samplingrate)
        
        motionManager.deviceMotionUpdateInterval = TimeInterval(1)

        motionManager.startAccelerometerUpdates(to: operationQueue, withHandler: accHandler)
    }

    func accHandler (data : CMAccelerometerData?, error: Error?) -> Void {
        print(data?.acceleration.x ?? 123)
    }
    
    
    
}
