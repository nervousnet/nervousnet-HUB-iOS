//
//  CoreMotionSensors.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 16.03.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import Foundation
import CoreLocation

enum CoreLocationError : Error {
    case authorizationError(CLAuthorizationStatus)
}

//This is the raw data. Apple offers some processing to remove known sources of noise, which we should discuss

class CoreLocationSensor : BaseSensor, CLLocationManagerDelegate {
    
    //TODO: Move these to the VM as singletons
    let locationManager = CLLocationManager()
    
    let operationQueue = OperationQueue.init()
    
    var authorizationStatus : CLAuthorizationStatus
    
    required public init (conf: BasicSensorConfiguration) {
        super.init(conf: conf)
        authorizationStatus = CLLocationManager.authorizationStatus()
        if  authorizationStatus  != CLAuthorizationStatus.restricted && authorizationStatus != CLAuthorizationStatus.denied {
            startListener()
        }
        else {
        }
        
    }
    
    func onConfChanged (){
        stopListener()
        startListener()
    }
    
    
    //TODO: add NSLocationAlwaysUSageDescription key to Info.plist
    override func startListener() -> Bool {
        locationManager.delegate? = self
        if authorizationStatus == CLAuthorizationStatus.notDetermined{
            locationManager.requestAlwaysAuthorization()
            
        }
                
    }
    
    override func stopListener() -> Bool {
        
        switch (configuration.sensorName.lowercased()){
        
        default:
            return false
        }
    
    }
    
    func locHandler (data : CLLocation?, error: Error?) -> Void {
        log.debug(data.debugDescription)
        
        let timestamp = getTimeStampMilliseconds()
        
        if data != nil {
            let lat = data!
            let long = data!
            let speed = data!
            
            super.push(reading: SensorReading(sensorID: configuration.sensorID, sensorName: configuration.sensorName, parameterNames: ["latitude", "longitude", "speed"], values: [lat, long, speed], timestamp: timestamp))
        }
        else {
            super.push(reading: SensorReading(sensorID: configuration.sensorID, sensorName: configuration.sensorName, parameterNames: ["latitude", "longitude", "speed"]))
        }
    }
    
  
    
    private func getTimeStampMilliseconds() -> Int64 {
        return Int64((Date.timeIntervalBetween1970AndReferenceDate + Date.timeIntervalSinceReferenceDate) * 1000)
    }
    
    //Delegate
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        <#code#>
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        <#code#>
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager, didUPdateTo: CLLocation, from: CLLocation) {
        <#code#>
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        <#code#>
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        <#code#>
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        <#code#>
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        <#code#>
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        <#code#>
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        <#code#>
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        <#code#>
    }
    
    
    func locationManager (_manager: CLLocationManager, didDetermineState: CLRegionState, for: CLRegion){
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        <#code#>
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        <#code#>
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        <#code#>
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        <#code#>
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        <#code#>
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        <#code#>
    }
    
    
}




