//
//  JSONConfigurationLoader.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 11.01.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import Foundation

class JSONConfigurationLoader {
    init () {}
    
    func load () -> [BasicSensorConfiguration]{
        return [BasicSensorConfiguration()]
    }
}

public class JsonConfigurationLoader {
    
    private var CONF_FILE_NAME : String = "sensors_configuration.json"
    private let LOG_TAG : String = String(describing: JsonConfigurationLoader.self)

//    private Context context;
//    
//    protected JsonConfigurationLoader(Context context) {
//        this.context = context;
//    }
    
    internal func load () -> [BasicSensorConfiguration] {
        var list = [BasicSensorConfiguration]()
        do{
            if let file = Bundle.main.url(forResource: "sensors_configuration", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                //print(json)
                if let dictionary = json as? [String: Any] {
                    
                    //print(dictionary["sensors_configurations"] as! [Any])
                    
                    if let sensorConfList = dictionary["sensors_configurations"] as? [Any] {
                        for conf in sensorConfList{
                            let sensorConf = ((conf as! [String:Any]))
                            
                            var values = [String:Any]()
                            
                            
                            if let sensorID = sensorConf ["sensorID"] as? Int64{
                                print("sensorID is", sensorID)
                                values["sensorID"] = sensorID
                            }
                            else {
                                print("no ID")
                                values["sensorID"] = -1 as! Int64
                            }
                            
                            if let sensorName = sensorConf["sensorName"] as? String{
                                print("sensorName is", sensorName)
                                values["sensorName"] = sensorName
                            }
                            else {
                                print("no Name")
                                values["sensorName"] = "-1"
                            }
                            
                            if let parameterNames = sensorConf["parametersNames"] as? [String] {
                                print("parameterNames are", parameterNames)
                                values["parameterNames"] = parameterNames
                            }
                            else {
                                print("no parameterNames")
                                values["parameterNames"] = ["-1"]
                            }
                            
                            if let parameterTypes = sensorConf["parametersTypes"] as? [String]{
                                print("parameterTypes are", parameterTypes)
                                values["parameterTypes"] = parameterTypes
                            }
                                
                            else {
                                print("no parameterTypes")
                                values["parameterTypes"] = ["-1"]
                            }
                            
                            if let samplingrates = sensorConf["samplingRates"] as? [Int64]{
                                print("samplingRates are", samplingrates)
                                values["samplingRates"] = samplingrates
                            }
                            else {
                                print("no samplingrates")
                                values["samplingRates"] = [-1] as! [Int64]
                            }
                            
                            if let state = sensorConf["initialState"] as? Int {
                                print("state is", state)
                                values["state"] = state
                            }
                                
                            else {
                                print("no state")
                                values["state"] = -1 as! Int
                            }
                            
                            
                            
                            print("creating Object")
                            
                            list.append(BasicSensorConfiguration(sensorID: values["sensorID"] as! Int64, sensorName: values["sensorName"] as! String, parameterNames: values["parameterNames"] as! [String], parameterTypes: values["parameterTypes"] as! [String], samplingrates: values["samplingRates"] as! [Int64], state: values["state"] as! Int))
                        }
                    }
                }
            }
            else {
                print("no file")
            }
        }catch{(error.localizedDescription)}
        
        
        
        return list
    }
    
    internal static func load (strJson : String) -> [BasicSensorConfiguration] {
        var list = [BasicSensorConfiguration]()
        let json = try? JSONSerialization.jsonObject(with: strJson, options: [])
        
        if let dictionary = jason as? [String: Any] {
            if let sensorConfList = dictionary["sensors_configurations"] as? [String: Any] {
                for sensorConf in sensorConfList{
                    var sensorID : Int = sensorConf["sensorID"]
                    var sensorName : String = sensorConf["sensorName"]
                    let parametersNames = sensorConf["parametersNames"] as? [String]
                }
            }
            
            for (key, value) in dictionary {
                // access all key / value pairs in dictionary
            }
            
            if let nestedDictionary = dictionary["anotherKey"] as? [String: Any] {
                // access nested dictionary values by key
            }
        }
        
        return list
    }
    
}



