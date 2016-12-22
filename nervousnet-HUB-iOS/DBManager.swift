//
//  NervousnetDBManager.swift
//  nervousnet-HUB-iOS
//
//  Created by Enz  Andreas on 14.12.16.
//  Copyright © 2016 ETH Zurich - COSS. All rights reserved.
//

import Foundation
import SQLite

class DBManager {
    
    //DB manager as a singleton
    public static let sharedInstance = DBManager()
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
            //TODO: how to proceed with failed DB connection?
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
    public func deleteTableIfExists(config: GeneralSensorConfiguration) {
        let table = Table(getTableName(config.sensorID))
        
        do {
            try DBCON?.run(table.drop(ifExists: true))
            log.info("DB Table \(self.getTableName(config.sensorID)) dropped")
        } catch _ {
            //TODO: in general, how to handle failed DB connection - if at all?
            log.error("No DB connection - could not create new table")
        }
    }
    
    
    public func createTableIfNotExists(config : GeneralSensorConfiguration) {
        
        let table = Table(getTableName(config.sensorID))
        
        do {
            try DBCON?.run(table.create(ifNotExists: true) { t in
                t.column(DBConstants.COLUMN_ID, primaryKey: .autoincrement)
                t.column(DBConstants.COLUMN_TIMESTAMP)
                
                for (name, type) in config.parameterDef {
                    
                    
                    switch(type) {
                    case .int_t:
                        t.column(DBConstants.COLUMN_TYPE_INTEGER(withName: name))
                    case .double_t:
                        t.column(DBConstants.COLUMN_TYPE_REAL(withName: name))
                    case .string_t:
                        t.column(DBConstants.COLUMN_TYPE_TEXT(withName: name))
                    }
                }

            })
            log.info("DB Table \(self.getTableName(config.sensorID)) available")
        } catch _ {
            //TODO: in general, how to handle failed DB connection - if at all?
            log.error("No DB connection - could not create new table")
        }
    }
    
    
    /// HELPER FUNCTIONS
    
    private func getTableName(_ sensorID : Int64) -> String {
        return "ID\(sensorID)"
    }
    
    
}
