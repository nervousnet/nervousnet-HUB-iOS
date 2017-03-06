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
    
    /*internal func load() -> [BasicSensorConfiguration]{
        
        var line : String = ""
        var total : String = ""
        //try {
        BufferedReader reader = new BufferedReader(new InputStreamReader(context.getAssets().open(CONF_FILE_NAME)))
        //try {
        while ((line = reader.readLine()) != null){
            total += line
        }
        //catch (Exception e){e.printStackTrace();}
        //catch (Exception e){Log.d(LOG_TAG, "ERROR " + e.getMessage());}
        return load(total);
    }*/
    
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


{
    "name": "Caffè Macs",
    "coordinates": {
        "lat": 37.330576,
        "lng": -122.029739
    },
    "meals": ["breakfast", "lunch", "dinner"]
}

extension Restaurant {
    init?(json: [String: Any]) {
        guard let name = json["name"] as? String,
            let coordinatesJSON = json["coordinates"] as? [String: Double],
            let latitude = coordinatesJSON["lat"],
            let longitude = coordinatesJSON["lng"],
            let mealsJSON = json["meals"] as? [String]
            else {
                return nil
        }
        
        var meals: Set<Meal> = []
        for string in mealsJSON {
            guard let meal = Meal(rawValue: string) else {
                return nil
            }
            
            meals.insert(meal)
        }
        
        self.name = name
        self.coordinates = (latitude, longitude)
        self.meals = meals
    }
}
