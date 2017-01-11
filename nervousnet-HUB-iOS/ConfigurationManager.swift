//
//  ConfigurationManager.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 11.01.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import Foundation

public class ConfigurationManager : iConfigurationManager {
    
    var configMap : [Int64 : GeneralSensorConfiguration]
    var stateDBManager :StateDBManager
    
    public init () {
        self.configMap = [:]
        self.stateDBManager =  StateDBManager()
        var loader = JSONConfigurationLoader()
        
        var confList : [BasicSensorConfiguration] = loader.load();
        for  conf in confList {
            
            configMap[conf.sensorID] = conf
            
            //try {
            var state : Int = stateDBManager.getSensorState(sensorID: conf.sensorID);
            conf.setState(state);
//            } catch (NoSuchElementException e) {
//            stateDBManager.storeSensorState(conf.getSensorID(), conf.getState());
//            }
        }
    }
    
    
    public func getAllConfigurations() -> [GeneralSensorConfiguration]{
        return configMap.values
    }
    
    public func getSensorIDs() {
        return (configMap.keys as! [Int64])
    }
    
    public func getConfiguration(sensorID : Int64) throws -> GeneralSensorConfiguration { //NoSuchElementException
        //if configMap.keys.contains(sensorID) {
            return configMap[sensorID]!
        //}
        //else
        //throw new NoSuchElementException("Sensor " + sensorID + " has not been configured.");
    }
    
    public func getSensorState(sensorID : Int64) throws -> Int {//NoSuchElementException
        //if configMap.keys.contains(sensorID) {
        return (configMap[sensorID] as! BasicSensorConfiguration).state
        //else
        //throw new NoSuchElementException("Sensor " + sensorID + " has not been configured.");
    }
    
    public func setSensorState(sensorID : Int64, state: Int) throws -> Void { //NoSuchElementException
        //if configMap.keys.contains(sensorID) {
        stateDBManager.storeSensorState(sensorID  : sensorID, state: state);
        (configMap[sensorID] as! BasicSensorConfiguration).setState(state);
        //}
        //else
        //throw new NoSuchElementException("Sensor " + sensorID + " has not been configured.");
    }
    
    public func getNervousnetState() throws -> Int{ //NoSuchElementException
        //try {
        return stateDBManager.getNervousnetState();
        //} catch (NoSuchElementException e) {
        //return NervousnetVMConstants.STATE_PAUSED;
        //}
    }
    
    public func setNervousnetState(state :Int) throws -> Void {//NoSuchElementException {
        stateDBManager.storeNervousnetState(state);
    }
    
}
