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
            self.initSensor(withConfig: config as! BasicSensorConfiguration)
        }
        
        if configManager.getNervousState() == VMConstants.NervousState.RUNNING {
            startSensors()
        }
    }
    
    
    
    
    
    /// SENSOR CONTROL METHODS
    /// ======================
    
    private func initSensor(withConfig config : BasicSensorConfiguration) -> BaseSensor {
        
        return BaseSensor()
    }
    
    public func startSensors() {
        for sensorID in configManager.getSensorIDs() {
            startSensor(withID: sensorID)
        }
    }
    
    public func startSensor(withID id : Int64) {
        
    }
    
    
    
    
    
    /// UUID METHODS
    /// ============
    
    //TODO: make this synchronized. how??
    // http://stackoverflow.com/questions/24045895/what-is-the-swift-equivalent-to-objective-cs-synchronized
    public func newUUID() {
        uuid = UUID()
        //FIXME: make sure that UUID is the same as android ID. Otherwise DB processing might be quite annoying (plus data about OS of user is leaked to the public)
    }
    
    
    
    
    
    
    
}
