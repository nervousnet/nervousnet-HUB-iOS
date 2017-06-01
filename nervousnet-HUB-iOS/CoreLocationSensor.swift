//
//  CoreMotionSensors.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 16.03.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import Foundation
import XCGLogger

import CoreLocation

enum CoreLocationError : Error {
    case authorizationError(CLAuthorizationStatus)
}

//This is the raw data. Apple offers some processing to remove known sources of noise, which we should discuss

@available(iOS 10.0, *)
class CoreLocationSensor : BaseSensor, CLLocationManagerDelegate {
    
    //TODO: Move these to the VM as singletons
    let locationManager = CLLocationManager()
    
    
    var authorizationStatus : CLAuthorizationStatus = CLAuthorizationStatus.notDetermined
    
    var timer : Timer = Timer.init()
    
    let operationQueue = OperationQueue.init()

    
    required public init (conf: BasicSensorConfiguration) {
        //TODO: check if parameter Dimension is as required 3
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
        locationManager.delegate = self
        if authorizationStatus == CLAuthorizationStatus.notDetermined{
            locationManager.requestAlwaysAuthorization()
        }
        
        if  authorizationStatus  != CLAuthorizationStatus.restricted && authorizationStatus != CLAuthorizationStatus.denied {
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(super.configuration.samplingrate), repeats: true, block: {timer in self.locationManager.requestLocation()})
            return true
        }

        print("failed")

        return false
    }
    
    override func stopListener() -> Bool {
        
        timer.invalidate()
        return false
    }
    
    func locHandler (data : CLLocation?, time : Date, error: Error?) -> Void {
        log.debug(data.debugDescription)
        
        let timestamp = Int64(time.timeIntervalSince1970 * 1000)
        
        if data != nil {
            let lat = data!.coordinate.latitude
            let long = data!.coordinate.longitude
            let speed = data!.speed
//            print(lat, long, speed)
            do {
                let sensorReading =  try SensorReading(config: super.configuration, values: [lat, long, speed], timestamp: timestamp)
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
    
  
    
    
    //Delegate
    
    func locationManager (didupdateLocations : [CLLocation]){
        print("wtf is this?")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            locHandler(data: location, time : location.timestamp, error: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locHandler(data: nil, time: Date.init(), error: error)
    }
    
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager, didUPdateTo: CLLocation, from: CLLocation) {
        
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
     
    }
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
         return false
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
    }
    
    
    func locationManager (_manager: CLLocationManager, didDetermineState: CLRegionState, for: CLRegion){
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
    
}




