//
//  nervousnet_HUB_iOSTests.swift
//  nervousnet-HUB-iOSTests
//
//  Created by prasad on 21/09/16.
//  Copyright © 2016 ETH Zurich - COSS. All rights reserved.
//
/* The basic structure of a test function is as follows:
 * - the name of the function needs to have prefix 'test'
 * - the function takes no parameters and returns void
 * - compute something
 * - check the result of computation against expected result using assertion:
 *   see 'Assertions Listed by Category' on 
 *   https://developer.apple.com/library/content/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/04-writing_tests.html
 *
 * example:
 * func testExample() {
 *      let value = testSomething()
 *      XCTAssertEquals(value, 5)
 * }
 */

import XCTest
@testable import nervousnet_HUB_iOS

class nervousnet_HUB_iOSTests: XCTestCase {
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssert(true)
    }
    
    
    ///Testing the sensor data DB
    func testDB() {
        let dbManager = DBManager.sharedInstance
        
        let sID : Int64 = 0
        let sName = "testSensor"
        let paramNames = ["x", "y","z"]
        let paramTypes = ["String", "String","int"]
        
        
        let config = GeneralSensorConfiguration(sensorID: sID, sensorName: sName, parameterNames: paramNames, parameterTypes: paramTypes)
        do { try dbManager.createTableIfNotExists(config: config) } catch _ { print("creating table failed") }
        
        try! dbManager.removeOldReadings(sensorID: sID, laterThan: 0)
        
        let x1 = try! dbManager.getReadings(with: config)
        XCTAssertEqual(0, x1.count)

        
        var reading = SensorReading()
        for i : Int64 in 1...10 {
            reading = SensorReading(sensorID: sID, sensorName: sName, parameterNames: paramNames, values: ["test", "test", i])
            let ts : Int64 = i + 1000
            reading.timestampEpoch = ts
            dbManager.store(reading: reading)
        }
        
        
        
        let latest = try! dbManager.getLatestReading(sensorID: sID)
        XCTAssertEqual(latest.values![2] as! Int64, reading.values![2] as! Int64)
        
        
        let x2 = try! dbManager.getReadings(with: config)
        XCTAssertEqual(10, x2.count)
        
    }
    
    
    ///Testing the sensor state DB
    func testStateDB() {
        let dbManager = StateDBManager.sharedInstance
        let nState = 3
        let sState = 1
        let sensorID : Int64 = 0
        
        dbManager.createConfigTableIfNotExists()
        dbManager.createNervousnetConfigTableIfNotExists()
        
        dbManager.storeNervousNetState(state: nState)
        dbManager.storeSensorState(sensorID: sensorID, state: sState)
        
        let nStateRet = try! dbManager.getNervousnetState()
        let sStateRet = try! dbManager.getSensorState(sensorID: sensorID)
        
        XCTAssertEqual(nState, nStateRet    )
        XCTAssertEqual(sState, sStateRet)
    }
    
    
    func testAxonController() {
        let axonServerController = AxonServerController()
    }
    
    
    func testSensorDataPush() {
        
        let sID : Int64 = 6544654
        let sName = "accelerometer"
        let paramNames = ["accX", "accY","accZ"]
        let paramTypes = ["double", "double", "double"]
        
        //let vm = VM() //TODO: initializing needs to handle DB connections (make sure they are available)
        
        let config = BasicSensorConfiguration(sensorID: sID, sensorName: sName, parameterNames: paramNames,
                                              parameterTypes: paramTypes, samplingrates: [1, 2, 3], state: 1)
        
        let sensor = CoreMotionSensor(conf: config)
 
        let dbManager = DBManager.sharedInstance
        try! dbManager.createTableIfNotExists(config: config)
        sensor.start()
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
