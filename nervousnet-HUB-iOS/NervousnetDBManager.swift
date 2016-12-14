//
//  NervousnetDBManager.swift
//  nervousnet-HUB-iOS
//
//  Created by Enz  Andreas on 14.12.16.
//  Copyright © 2016 ETH Zurich - COSS. All rights reserved.
//

import Foundation
import SQLite

class NervousnetDBManager {
    
    //DB manager as a singleton
    public static let sharedInstance = NervousnetDBManager()
    private let DBCON : Connection?
    
    //TODO make sure DB operations run on background thread
    
    
    private init() {
        //setup DB (if necessary)
        
        //dbconnection
        
        let path = NSSearchPathForDirectoriesInDomains( //currently DB is stored in Documents folder of the app
            .documentDirectory, .userDomainMask, true
            ).first!
        
        
        do {
            DBCON = try Connection("\(path)/\(DBConstants.DB_NAME)")
            log.info("Database connection established")
        } catch _ {
            log.severe("Failed to connect to the database, trying to proceed without")
            DBCON = nil
        }
    }
    
    
    
    
    /// DATABASE QUERIES
    /// ==================
    
    //TODO: add proper function signature and return types
    /// SENSOR DATA READ QUERIES
    /*
    public func getLatestReading() {}
    public func getReadings() {}
    public func getReadings() {}
    public func getReadings() {}
    public func getLatestReadingUnderRange() {}
    public func getReadings() {}
    */
    
    /// SENSOR DATA WRITE QUERIES
    /*
    public func store() {}
    public func store() {}
    public func store() {}
    */
    
    /// SENSOR DATA DELETE QUERIES
    
    public func removeOldReadings() {}
 
    
    /// DB SETUP QUERIES
    public func deleteTableIfExists() {}
    
    
    public func createTableIfNotExists(config : GeneralSensorConfiguration) {
        
        let table = Table(getTableName(config.sensorID))
        
        do {
            try DBCON?.run(table.create(ifNotExists: true) { t in
                t.column(DBConstants.COLUMN_ID, primaryKey: .autoincrement)
                t.column(DBConstants.COLUMN_TIMESTAMP)
                
                for (name, type) in config.parameterDef {
                    
                    
                    switch(type) {
                    case "int":
                        t.column(DBConstants.COLUMN_TYPE_INTEGER(withName: name))
                    case "double":
                        t.column(DBConstants.COLUMN_TYPE_REAL(withName: name))
                    case "String":
                        t.column(DBConstants.COLUMN_TYPE_TEXT(withName: name))
                    default:
                        log.error("unexpected parameter type, not creating table")
                        return
                    }
                }

            })
        } catch _ {
            //TODO: in general, how to handle failed DB connection - if at all?
        }
    }
    
    
    /// HELPER FUNCTIONS
    
    private func getTableName(_ sensorID : UInt64) -> String {
        return "ID\(sensorID)"
    }
    
    
}
