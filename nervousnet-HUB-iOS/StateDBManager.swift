//
//  StateDBManager.swift
//  nervousnet-HUB-iOS
//
//  Created by Lewin Könemann on 11.01.17.
//  Copyright © 2017 ETH Zurich - COSS. All rights reserved.
//

import Foundation
import SQLite

class StateDBManager {
    
    
    enum DBError : Error {
        case NoSuchElementException
        case DBConnectionError
    }
    
    //DB manager as a singleton
    public static let sharedInstance = StateDBManager()
    private let DBCON : Connection?
    
    
    
    //TODO make sure DB operations run on background thread
    
    
    private init() {
        
        //dbconnection
        
        let path = NSSearchPathForDirectoriesInDomains( //currently DB is stored in Documents folder of the app
            .documentDirectory, .userDomainMask, true
            ).first!
        
        log.debug("path to DB is \(path)")

        do {
            DBCON = try Connection("\(path)/\(DBConstants.CONFIG_DATABASE_NAME)")
            log.info("Database connection established")
        } catch _ {
            //TODO: how to proceed with failed DB connection?
            log.severe("Failed to connect to the database, trying to proceed without")
            DBCON = nil
        }
        
        DBCON?.trace{log.debug($0)} //callback object that prints every executed SQL statement
        
        createConfigTableIfNotExists()
        createNervousnetConfigTableIfNotExists()
    }
    
    
    
    ////////////////////
    /// SENSOR STATE ///
    /// ============ ///
    
    
    
    public func createConfigTableIfNotExists() {
        
        let table = Table(DBConstants.SENSOR_CONFIG_TABLENAME)
        
        do {
            try DBCON?.run(table.create(ifNotExists: true) { t in
                t.column(DBConstants.COLUMN_ID, primaryKey: true)
                t.column(DBConstants.COLUMN_STATE)
            
            })
            log.info("DB Table \(DBConstants.SENSOR_CONFIG_TABLENAME) available.")
        } catch _ {
            log.error("No DB connection - could not create new table.")
        }
    }
    
    
    
    public func getSensorState (sensorID : Int64) throws -> Int {
        let table = Table(DBConstants.SENSOR_CONFIG_TABLENAME)
        let idColumn = DBConstants.COLUMN_ID
        
        let query = table.filter(idColumn == sensorID)
        
        return try fetchState(statement: query)
    }
    
    
    
    public func storeSensorState (sensorID : Int64, state : Int) {
        let table = Table(DBConstants.SENSOR_CONFIG_TABLENAME)
        let idColumn = DBConstants.COLUMN_ID
        let stateColumn = DBConstants.COLUMN_STATE
        
        do {
            try self.DBCON?.run(table.insert(or: .replace, idColumn <- sensorID, stateColumn <- state))
        } catch _ {
            log.error("unable to store sensor state into DB")
        }
    }
    
    
    
    
    ////////////////////////
    /// NERVOUSNET STATE ///
    /// ================ ///
    
    //only one row for the nervousnet state anyway, hardcode it for the query
    private static let nervousnet_row_id : Int64 = 0
    
    
    /* create the global nervousnet config table and initialize default values */
    public func createNervousnetConfigTableIfNotExists() {
        
        let table = Table(DBConstants.NERVOUSNET_CONFIG_TABLENAME)
        
        do {
            try DBCON?.run(table.create(ifNotExists: true) { t in
                t.column(DBConstants.COLUMN_ID, primaryKey: true)
                t.column(DBConstants.COLUMN_STATE)
                
            })
            
            /* If the above query did indeed create a new table, we also need to initialize 
             * the state values. Done by trying to get state info and storing default upon cought error
             */
            do { _ = try getNervousnetState() } catch DBError.NoSuchElementException {
                storeNervousNetState(state: VMConstants.STATE_RUNNING)
            }
            
            
            
            log.info("DB Table \(DBConstants.NERVOUSNET_CONFIG_TABLENAME) available.")
        } catch _ {
            log.error("No DB connection - could not create new table.")
        }
    }
    
    
    
    public func getNervousnetState() throws -> Int {
        let table = Table(DBConstants.NERVOUSNET_CONFIG_TABLENAME)
        let idColumn = DBConstants.COLUMN_ID
        
        let query = table.filter(idColumn == StateDBManager.nervousnet_row_id)
        
        return try fetchState(statement: query)
    }
    
    
    
    public func storeNervousNetState (state: Int) {
        let table = Table(DBConstants.NERVOUSNET_CONFIG_TABLENAME)
        let idColumn = DBConstants.COLUMN_ID
        let stateColumn = DBConstants.COLUMN_STATE
        
        do {
            try self.DBCON?.run(table.insert(or: .replace, idColumn <- StateDBManager.nervousnet_row_id,
                                             stateColumn <- state))
        } catch _ {
            log.error("unable to store nervousnet state into DB")
        }
    }
    
    
    
    
    // HELPER FUNCTION
    
    private func fetchState(statement : Table) throws -> Int {
        
        guard let db = DBCON else {
            log.error("No DB connection - could not fetch state.")
            throw DBError.DBConnectionError
        }
        
        let stateColumn = DBConstants.COLUMN_STATE
        
        for row in try db.prepare(statement) {
            //just return first result in list (there should be only this one)
            return row[stateColumn]
        }
        
        //error only reached if the statement returns no elements (invalid sql OR empty table)
        throw DBError.NoSuchElementException
    }
    
    
}
