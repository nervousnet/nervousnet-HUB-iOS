//
//  NervousnetDBManager.swift
//  nervousnet-HUB-iOS
//
//  Created by Enz  Andreas on 14.12.16.
//  Copyright © 2016 ETH Zurich - COSS. All rights reserved.
//
// Built on SQLite.swift, check documentation https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md
// syntax of SQLite.swift can be a bit weird but IMHO it is better than writing SQL strings in the long run


import Foundation
import SQLite

class DBManager {
    
    //DB manager as a singleton
    public static let sharedInstance = DBManager()
    private let DBCON : Connection?
    
    //scheduler to periodicaly store values from cache
    private let scheduler = Timer.scheduledTimer(timeInterval: 10, //seconds
                                                 target: sharedInstance,
                                                 selector: #selector(run),
                                                 userInfo: nil,
                                                 repeats: true)
    
    
    //cache
    private var TEMPORARY_STORAGE : [Int64 : [SensorReading]] = [:]
    
    private var LATEST_SENSOR_DATA : [Int64 : SensorReading] = [:]
    
    
    
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
    
    public func store(reading : SensorReading) {
        
        guard let id = reading.sensorID else {
            log.error("Cannot store Reading without sensor ID");
            return
        }
        
        LATEST_SENSOR_DATA[id] = reading
        
        //store value in TEMP_STORAGE in the correct list
        if var list = TEMPORARY_STORAGE[id] {
            list.append(reading)
        } else {
            TEMPORARY_STORAGE[id] = [reading]
        }
    }
    
    
    public func store(readings : [SensorReading]) {
        //TODO
    }
    
    
    private func store(cache : [Int64 : [SensorReading]]) {
        
        do {
            try DBCON?.transaction {
                
                for (sensorID, readingList) in cache {
                    let table = Table(self.getTableName(sensorID))
                    
                    for reading in readingList {
                        guard let values = reading.values else {
                            log.error("SensorReading did not contain a list of values")
                            return
                        }
                        
                        var setters : [Setter] = [] //TODO: add setters -> do it outside the readingList loop since it stays the same for a specific sensorID (at least the column part of the insert statement, not the value part)
                        
                        for param in values {
                            //construct setters
                        }
                        
                        
                        try self.DBCON?.run(table.insert(setters))
                    }
                }
                
            }
            
        } catch {
            log.error("Unable to do DB transaction insert of SensorReading cache")
        }

    }
    
    
    /// SENSOR DATA DELETE QUERIES
    
    public func removeOldReadings(sensorID : Int64, laterThan timestamp : Int64) { //MARK: synchronized in android. why?
        let table = Table(getTableName(sensorID))
        
        let oldEntries = table.filter(DBConstants.COLUMN_TIMESTAMP < timestamp)
        
        //DELETE FROM ID<sensorID> WHERE <TS> < timestamp;
        
        do {
            try DBCON?.run(oldEntries.delete())
            log.info("Removed old entires in DB Table \(self.getTableName(sensorID)).")
        } catch {
            //TODO: in general, how to handle failed DB connection - if at all?
            log.error("No DB connection - could not drop old Readings.")
        }
        
        
    }
 
    
    
    /// DB SETUP QUERIES
    public func deleteTableIfExists(config: GeneralSensorConfiguration) {
        let table = Table(getTableName(config.sensorID))
        
        do {
            try DBCON?.run(table.drop(ifExists: true))
            log.info("DB Table \(self.getTableName(config.sensorID)) dropped.")
        } catch _ {
            //TODO: in general, how to handle failed DB connection - if at all?
            log.error("No DB connection - could not delete table.")
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
            log.info("DB Table \(self.getTableName(config.sensorID)) available.")
        } catch _ {
            //TODO: in general, how to handle failed DB connection - if at all?
            log.error("No DB connection - could not create new table.")
        }
    }
    
    
    
    /// HELPER FUNCTIONS
    
    private func getTableName(_ sensorID : Int64) -> String {
        return "ID\(sensorID)"
    }

    
    /// SCHEDULER
    
    //stores all cached reading values into the DB
    @objc func run() {
        let start = DispatchTime.now()
        store(cache: TEMPORARY_STORAGE)
        let finish = DispatchTime.now()
        
        TEMPORARY_STORAGE.removeAll()
        
        
        let duration = Double(finish.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000.0
        log.info("Storing the cached values to DB took \(duration) ms")
    }
    
    
}
