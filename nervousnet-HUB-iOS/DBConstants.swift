//
//  DBConstants.swift
//  nervousnet-HUB-iOS
//
//  Created by Enz  Andreas on 14.12.16.
//  Copyright © 2016 ETH Zurich - COSS. All rights reserved.
//

import Foundation
import SQLite

struct DBConstants {
    
    static let DB_NAME = "sensordb.sqlite3"
    
    static let COLUMN_ID_NAME = "ID"
    static let COLUMN_TIMESTAMP_NAME = "timestamp"
    
    static var COLUMN_ID : Expression<Int64> {
        return COLUMN_TYPE_INT64(withName: COLUMN_ID_NAME)
    }
    
    static var COLUMN_TIMESTAMP : Expression<Int64> {
        return COLUMN_TYPE_INT64(withName: COLUMN_TIMESTAMP_NAME)
    }
    
    
    //CONFIG DB CONSTANTS
    //====================
    
    static let CONFIG_DATABASE_NAME : String = "ConfigDB.sqlite3"
    static let NERVOUSNET_CONFIG_TABLENAME : String = "ConfigNervousnetTable"

    
    //static let DATABASE_VERSION : Int = 1
    static let SENSOR_CONFIG_TABLENAME : String = "ConfigTable"
    static let COLUMN_STATE_NAME : String = "State"
    

    static var COLUMN_STATE : Expression<Int> {
        return COLUMN_TYPE_INT(withName: COLUMN_STATE_NAME)
    }
    
    
    
    
    //DB types mapping from swift to SQLite3
    //(src: https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#building-type-safe-sql)
    
    static func COLUMN_TYPE_INT64(withName name : String) -> Expression<Int64> {
        return Expression<Int64>(name)
    }
    
    static func COLUMN_TYPE_INT(withName name : String) -> Expression<Int> {
        return Expression<Int>(name)
    }

    
    static func COLUMN_TYPE_REAL(withName name : String) -> Expression<Double> {
        return Expression<Double> (name)
    }
    
    static func COLUMN_TYPE_TEXT(withName name : String) -> Expression<String> {
        return Expression<String> (name)
    }
}
