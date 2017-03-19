//
//  locationTest.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 19.03.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import XCTest
@testable import nervousnet_HUB_iOS


class locationTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    @available(iOS 10.0, *)
    func testExample() {
        
        let sID : Int64 = 6544654
        let sName = "accelerometer"
        let paramNames = ["accX", "accY","accZ"]
        let paramTypes = ["double", "double", "double"]
        
        
        let config = BasicSensorConfiguration(sensorID: sID, sensorName: sName, parameterNames: paramNames,
                                              parameterTypes: paramTypes, samplingrates: [1, 2, 3], state: 1)
        
        let locationSensor = CoreLocationSensor(conf: config)
        
        locationSensor.startListener()
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
