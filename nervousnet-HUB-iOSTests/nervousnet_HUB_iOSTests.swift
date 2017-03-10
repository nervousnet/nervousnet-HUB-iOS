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
    
    
    func testDB() { // test functions need to have prefix 'test', take no parameters, and return void
        let dbManager = DBManager.sharedInstance
        
        let sID : Int64 = 0
        let sName = "testSensor"
        let paramNames = ["x", "y","z"]
        let paramTypes = ["String", "String","int"]
        
        
        let config = GeneralSensorConfiguration(sensorID: sID, sensorName: sName, parameterNames: paramNames, parameterTypes: paramTypes)
        do { try dbManager.createTableIfNotExists(config: config) } catch _ { print("creating table failed") }
        for i : Int64 in 1...10 {
            let reading = SensorReading(sensorID: sID, sensorName: sName, parameterNames: paramNames, values: ["test", "test", i])
            let ts : Int64 = i + 1000
            reading.timestampEpoch = ts
            dbManager.store(reading: reading)
        }
    }
    
    func testAxonController() {
        let axonServerController = AxonServerController()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
