//
//  StateDBManager.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 11.01.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import Foundation

class StateDBManager {
    static var sensorState : Int = 0
    
    init () {}
    
    
    
    public func getSensorState (sensorID : Int64) -> Int{
        return 0
    }
    
    public func storeSensorState (sensorID: Int64, state : Int) -> Void {
    }
    
    public func getNervousnetState() -> Int {
        return 0
    }
    
    public func storeNervousNetState (state: Int) -> Void{
    }
    
    
}
