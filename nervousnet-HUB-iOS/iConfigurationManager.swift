//
//  iConfigurationManager.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 14.12.16.
//  Copyright © 2016 ETH Zurich - COSS. All rights reserved.
//

import Foundation

protocol iConfigurationManager {
    
    func getAllConfigurations() -> [GeneralSensorConfiguration]
    
    func getSensorIDs () -> [Int64]
    
    func getConfiguration(sensorID : Int64) throws -> GeneralSensorConfiguration //NoSuchElementException
    
    func getSensorState(sensorID : Int64) throws -> Int //NoSuchElementException
    
    func setSensorState(sensorID : Int64, state : Int) throws //NoSuchElementException
    
    func getNervousnetState() -> Int
    
    func setNervousnetState(state : Int)
}

