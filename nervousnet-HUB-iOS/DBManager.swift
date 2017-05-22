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
    
    enum DBError : Error {
        case NoSuchElementException
        case DBConnectionError
        case NoSuchColumnException
        case InvalidSensorReading
    }
    
    //DB manager as a singleton
    public static let sharedInstance = DBManager()
    private let DBCON : Connection?
    
    //Time interval of the background DB task
    private let SCHEDULE_INTERVAL = 10.0 //seconds
    
    //scheduler to periodicaly store values from cache, check function specified in selector
    private var scheduler = Timer()
    
    
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
        
        log.debug("path to DB is \(path)")

        
        do {
            DBCON = try Connection("\(path)/\(DBConstants.DB_NAME)")
            log.info("Database connection established")
        } catch _ {
            //TODO: how to proceed with failed DB connection?
            log.severe("Failed to connect to the database, trying to proceed without")
            DBCON = nil
        }
        
        /*
        * We need to add timer to the main runloop. otherwise the scheduled events do not call
        * the 'run' method properly. 
        * TODO: does the db transaction run on the main thread now? or does SQLite handle this on
        * a different thread?
        */
        scheduler = initDBScheduler()
        
        //DBCON?.trace{log.debug($0)} //callback object that prints every executed SQL statement
    }
    
    
    
    
    /// DATABASE QUERIES (WITH CACHING)
    /// ==================
    

    /// SENSOR DATA READ QUERIES
    
    
    /*
     * Returns latest reading that has been stored since starting the application.
     */
    public func getLatestReading(sensorID : Int64) throws -> SensorReading {
        if let reading = LATEST_SENSOR_DATA[sensorID] {
            return reading
        }
        else {
            throw DBError.NoSuchElementException
        }
    }
    
    
    /*
     * Returns list of all readings for a sensor specified in config.
     */
    public func getReadings(with config : GeneralSensorConfiguration) throws -> [SensorReading] {
        let table = Table(getTableName(config.sensorID))
        
        // SELECT * FROM <table>
        let query = table //no specific select necessary since we want the whole table
        
        return try getReadings(with: config, using: query)
    }
    
    
    /*
     * Returns list of readings in the interval specified with start timestamp and stop timestamp in
     * milliseconds.
     */
    public func getReadings(with config : GeneralSensorConfiguration,
                            startTimestamp : Int64,
                            endTimestamp : Int64
                            ) throws -> [SensorReading] {
        
        let table = Table(getTableName(config.sensorID))
        let tsColumn = DBConstants.COLUMN_TIMESTAMP
        
        let query = table.filter(tsColumn >= startTimestamp && tsColumn <= endTimestamp)
        
        return try getReadings(with: config, using: query)
    }
    
    
    /*
     * Returns list of readings in the interval specified with start timestamp and stop timestamp in
     * milliseconds. Additionally, user can specify sensor parameter names to be selected. Other
     * sensor parameters are ignored.
     */
    public func getReadings(config : GeneralSensorConfiguration,
                            startTimestamp : Int64,
                            endTimestamp : Int64,
                            selectParameters : [String] //assumed to be column names
                            ) throws -> [SensorReading] {
        
        let table = Table(getTableName(config.sensorID))
        let tsColumn = DBConstants.COLUMN_TIMESTAMP
        
        let query = table.filter(tsColumn >= startTimestamp && tsColumn <= endTimestamp)
        
        return try getReadings(with: config, using: query, columns: selectParameters)
    }
    
    
    /*
     * Returns list of readings based on a manual sql query.
     */
    public func getReadings(with config : GeneralSensorConfiguration,
                            using query : Table,
                            columns : [String]? = nil) throws -> [SensorReading] {

        var resultList : [SensorReading] = []
        do {
            
            guard let db = DBCON else {
                log.error("No DB connection - could not fetch readings.")
                throw DBError.DBConnectionError
            }
            
            for row in try db.prepare(query) {
                
                
                let timeStamp = row[DBConstants.COLUMN_TIMESTAMP]
                
                let reading = SensorReading(config: config, timestamp: timeStamp)
                
                
                // iterate over all possible param names of this sensor config, load value from DB
                // if the param name is in the 'columns' list
                // this loop essentially implements a: SELECT <column with param name> ...
                for (name, type) in config.parameterNameToType {
                    
                    if let _ = columns?.contains(name) {
                    
                        var success = true
                        switch(type) { //TODO: change strings to enum type?
                        case "int":
                            let column = DBConstants.COLUMN_TYPE_INT64(withName: name)
                            success = reading.setValue(paramName: name, value: row[column])
                        case "double":
                            let column = DBConstants.COLUMN_TYPE_REAL(withName: name)
                            success = reading.setValue(paramName: name, value: row[column])
                        case "String":
                            let column = DBConstants.COLUMN_TYPE_TEXT(withName: name)
                            success = reading.setValue(paramName: name, value: row[column])
                        default:
                            log.error("unexpected DB type. unable to retrieve value")
                            continue
                        }
                        
                        if !success {
                            log.error("unable to set value of parameter \(name) ... skipping")
                            continue
                        }
                    }
                }

                
                resultList.append(reading)
            }
            
        } catch {
            log.error("No DB connection - could not fetch readings.")
            throw DBError.DBConnectionError
        }
        return resultList
    }

    
    
    
    
    /// SENSOR DATA WRITE QUERIES
    
    
    /*
     * Store reading into cache.
     */
    public func store(reading : SensorReading) {
        
        let id = reading.sensorConfig.sensorID
        
        LATEST_SENSOR_DATA[id] = reading
        
        //store value in TEMP_STORAGE in the correct list
        if TEMPORARY_STORAGE[id] != nil {
            TEMPORARY_STORAGE[id]?.append(reading)
        } else {
            TEMPORARY_STORAGE[id] = [reading]
        }
    }
    
    
    /*
     * Store list of readings directly to DB.
     */
    public func store(readings : [SensorReading]) {
        //TODO
    }
    
    
    /*
     * Store Cache into DB
     */
    private func store(cache : [Int64 : [SensorReading]]) throws {
        
        do {
            try DBCON?.transaction {
                
                for (sensorID, readingList) in cache {
                    let table = Table(self.getTableName(sensorID))
                    
                    for reading in readingList {
                        let parameters = reading.parameterNameToType
                        let ts = reading.timestampEpoch
                        
                        var setterList : [Setter] = []
                        
                        var setter : Setter
                        
                        setterList.append(DBConstants.COLUMN_TIMESTAMP <- ts)
 
                        for (name, _) in parameters {
                            //construct setters
                            let v = reading.getValue(paramName: name)
                            if v is Int64 {
                                setter = (DBConstants.COLUMN_TYPE_INT64(withName: name) <- v as! Int64)
                            }
                            else if v is Int {
                                setter = (DBConstants.COLUMN_TYPE_INT(withName: name) <- v as! Int)
                            }
                            else if v is Double {
                                setter = (DBConstants.COLUMN_TYPE_REAL(withName: name) <- v as! Double)
                            }
                            else if v is String {
                                setter = (DBConstants.COLUMN_TYPE_TEXT(withName: name) <- v as! String)
                            }
                            else {
                                log.error("unknown DB type (could be prevented by using enum and checking type earlier) ... skipping value")
                                continue
                            }
                            setterList.append(setter)
                        }
                        
                        
                        try self.DBCON?.run(table.insert(setterList))
                    }
                }
                
            }
            
        } catch {
            log.error("Unable to do DB transaction insert of SensorReading cache")
            throw DBError.DBConnectionError
        }

    }
    
    
    /// SENSOR DATA DELETE QUERIES
    
    /*
     * Delete readings that are older than threshold timestamp (milliseconds).
     */
    public func removeOldReadings(sensorID : Int64, laterThan timestamp : Int64) throws { //MARK: synchronized in android. why?
        let table = Table(getTableName(sensorID))
        
        let oldEntries = table.filter(DBConstants.COLUMN_TIMESTAMP < timestamp)
        
        //DELETE FROM ID<sensorID> WHERE <TS> < timestamp;
        
        do {
            try DBCON?.run(oldEntries.delete())
            log.info("Removed old entries in DB Table \(self.getTableName(sensorID)).")
        } catch {
            log.error("No DB connection - could not drop old Readings.")
            throw DBError.DBConnectionError
        }
        
        
    }
 
    
    
    /// DB SETUP QUERIES
    
    /*
     * Delete table of a sesnor.
     */
    public func deleteTableIfExists(config: GeneralSensorConfiguration) throws {
        let table = Table(getTableName(config.sensorID))
        
        do {
            try DBCON?.run(table.drop(ifExists: true))
            log.info("DB Table \(self.getTableName(config.sensorID)) dropped.")
        } catch _ {
            log.error("No DB connection - could not delete table.")
            throw DBError.DBConnectionError
        }
    }
    
    
    /*
     * Create table for a sensor. Configuration of a sensor has to be passed.
     */
    public func createTableIfNotExists(config : GeneralSensorConfiguration) throws {
        
        let table = Table(getTableName(config.sensorID))
        
        do {
            try DBCON?.run(table.create(ifNotExists: true) { t in
                t.column(DBConstants.COLUMN_ID, primaryKey: .autoincrement)
                t.column(DBConstants.COLUMN_TIMESTAMP)
                
                for (name, type) in config.parameterNameToType {

                    switch(type) { //TODO: change strings to enum type?
                    case "int":
                        t.column(DBConstants.COLUMN_TYPE_INT64(withName: name))
                    case "double":
                        t.column(DBConstants.COLUMN_TYPE_REAL(withName: name))
                    case "String":
                        t.column(DBConstants.COLUMN_TYPE_TEXT(withName: name))
                    default:
                        log.error("unexpected DB type. skipping creation of column")
                        continue
                    }
                    
                }
 

            })
            log.info("DB Table \(self.getTableName(config.sensorID)) available.")
        } catch {
            log.error(error.localizedDescription)
            log.error("No DB connection - could not create new table.")
            throw DBError.DBConnectionError
        }
    }
    
    
    
    /// HELPER FUNCTIONS
    
    private func getTableName(_ sensorID : Int64) -> String {
        return "ID\(sensorID)"
    }
    
    
    /// SCHEDULER
    
    //Init the scheduler
    private func initDBScheduler() -> Timer {
        scheduler = Timer(timeInterval: SCHEDULE_INTERVAL, //seconds
            target: self,
            selector: #selector(doScheduledTask),
            userInfo: nil,
            repeats: true)
        
        RunLoop.main.add(scheduler, forMode: .defaultRunLoopMode)
        
        return scheduler
    }
    
    /*
     * Start periodic storage of readings. If run method is not called, readings will not be
     * stored into database but will be kept only in cache.
     */
    @objc private func doScheduledTask() {
        let start = DispatchTime.now()
        //FIXME: lock the cache until all values are stored (or another mechanism to prevent loss of values through multithreading)
        objc_sync_enter(TEMPORARY_STORAGE);
        do {
            try store(cache: TEMPORARY_STORAGE)
        } catch _ {
            log.error("Cache could not be written to db. dropping cache anyway")
        }
        
        let finish = DispatchTime.now()
        
        TEMPORARY_STORAGE.removeAll()
        objc_sync_exit(TEMPORARY_STORAGE);

        
        let duration = Double(finish.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000.0
        log.info("Storing the cached values to DB took \(duration) ms")
    }
    
    
    /*
     * Start and Stop the scheduler, clear latest reading
     */
    
    // It is assumed that sensors are not sending values to the DB cache if the scheduler ist stopped.
    // If sensors are still running and the DB does not store and clear cached values, the cache will grow forever
    public func stopScheduledTask() {
        //stop scheduler
        scheduler.invalidate()
        //make sure all values are stored and cache cleared
        doScheduledTask()
        //empty latest reading cache
        LATEST_SENSOR_DATA = [:]
    }
    
    public func startScheduledTask() {
        scheduler = initDBScheduler()
    }
    
    
    
}
