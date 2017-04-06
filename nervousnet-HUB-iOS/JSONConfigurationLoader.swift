//
//  JSONConfigurationLoader.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 11.01.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import Foundation



public class JSONConfigurationLoader {
    
    private var CONF_FILE_NAME : String = "sensors_configuration"
    private let LOG_TAG : String = String(describing: JSONConfigurationLoader.self)
    
    init (){
    }

//    private Context context;
//
//    protected JsonConfigurationLoader(Context context) {
//        this.context = context;
//    }
    
    internal func load (data : Data) -> [BasicSensorConfiguration] {
        var list = [BasicSensorConfiguration]()
        do{
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as Any?{
                //log.debug(json)
                if let dictionary = json as? [String: Any] {
                    
                    //log.debug(dictionary["sensors_configurations"] as! [Any])
                    
                    if let sensorConfList = dictionary["sensors_configurations"] as? [Any] {
                        
                        for conf in sensorConfList {
                            let sensorConf = ((conf as! [String:Any]))
                            
                            var values = [String:Any]()
                            
                            
                            if let sensorID = sensorConf ["sensorID"] as? Int64{
                                log.debug("sensorID is \(sensorID)")
                                values["sensorID"] = sensorID
                            }
                            else {
                                log.debug("no ID")
                                values["sensorID"] = -1 as! Int64
                            }
                            
                            if let sensorName = sensorConf["sensorName"] as? String{
                                log.debug("sensorName is \(sensorName)")
                                values["sensorName"] = sensorName
                            }
                            else {
                                log.debug("no Name")
                                values["sensorName"] = "-1"
                            }
                            
                            if let parameterNames = sensorConf["parametersNames"] as? [String] {
                                log.debug("parameterNames are \(parameterNames)")
                                values["parameterNames"] = parameterNames
                            }
                            else {
                                log.debug("no parameterNames")
                                values["parameterNames"] = ["-1"]
                            }
                            
                            if let parameterTypes = sensorConf["parametersTypes"] as? [String]{
                                log.debug("parameterTypes are \(parameterTypes)")
                                values["parameterTypes"] = parameterTypes
                            }
                                
                            else {
                                log.debug("no parameterTypes")
                                values["parameterTypes"] = ["-1"]
                            }
                            
                            if let samplingrates = sensorConf["samplingRates"] as? [Int64]{
                                log.debug("samplingRates are \(samplingrates)")
                                values["samplingRates"] = samplingrates
                            }
                            else {
                                log.debug("no samplingrates")
                                values["samplingRates"] = [-1] as! [Int64]
                            }
                            
                            if let state = sensorConf["initialState"] as? Int {
                                log.debug("state is \(state)")
                                values["state"] = state
                            }
                                
                            else {
                                log.debug("no state")
                                values["state"] = -1 as! Int
                            }
                            
                            
                            
                            log.debug("creating Object")
                            //create parameter definition map
                            var parameterDef = [String : String]()
                            for (name, type) in zip(values["parameterNames"] as! [String], values["parameterTypes"] as! [String]) {
                                parameterDef[name] = type
                            }
                            
                            list.append(BasicSensorConfiguration(sensorID: values["sensorID"] as! Int64, sensorName: values["sensorName"] as! String, parameterDef: parameterDef, samplingrates: values["samplingRates"] as! [Int64], state: values["state"] as! Int))
                        }
                    }
                }
            }
            else {
                log.debug("not a valid format")
            }
        }catch{(error.localizedDescription)}
        
        
        
        return list
    }

    
    internal func load () -> [BasicSensorConfiguration] {
        var list = [BasicSensorConfiguration]()
        do{
            if let file = Bundle.main.url(forResource: CONF_FILE_NAME, withExtension: "json", subdirectory: "Assets") {
                let data = try Data(contentsOf: file)
                list = self.load(data: data)
                //log.debug(json)
               
            }
            else {
                log.debug("no file")
            }
        }catch{(error.localizedDescription)}
        
        
        
        return list
    }
    
    internal func load (strJson : String) -> [BasicSensorConfiguration]{
        var list = [BasicSensorConfiguration]()
        do{
            if let data = try Data(base64Encoded: strJson) {
                
                list = self.load(data : data)
                //log.debug(json)
                
            }
            else {
                log.debug("not a Valid Data Format")
            }
        }catch{(error.localizedDescription)}
        
        
        
        return list
    }
    
    
}


