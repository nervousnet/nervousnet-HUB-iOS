//
//  AxonController.swift
//  nervousnet-iOS
//  
//  Created by Sam Sulaimanov on 03 Mar 2016.
//  Copyright (c) 2016 ETHZ . All rights reserved.
//


import Foundation
import Swifter

///
/// Manages the Axon (HTTP and Socket) server and its routes. Asks for permission on
/// behalf of the Axons.
///
class AxonServerController {
    
    // create an HttpServer using the Swifter pod
    var server = HttpServer()
    
    
    //resource paths
    let axonResourceDir = "\(Bundle.main.resourcePath!)/Assets/axon-resources/"
    let axonDir = "\(NSHomeDirectory())/Documents/nervousnet-installed-axons/"
    //let laeController = LAEController() TODO: connect to sensor data layer
    
    
    // TODO: remove later. for now provides sensor 'data'
    var pseudoSensorData: Int = 0

    
    
    init(){        
        startAxonHTTPServer()
    }
    
    
    // start the server and map the possible http request paths
    func startAxonHTTPServer(){
        
        do {
            try self.server.start()
            log.info("Server Started Successfully!")
            self.mapAxonHTTPServerRoutes()
        } catch {
            log.error("Server start error: \(error)")
        }
    }

    
    
    func restoreAxonHTTPServer(){
        self.startAxonHTTPServer()
    }
    
    
    
    /* map the possible http GET request this server can handle:
     * /                                    provides overview of available paths
     * /PATH_AXON_RES/static/:resource      serves static resources (e.g.: libs.js, styles.css)
     * /PATH_AXON_RES/:axonname/:resource   serves static axon-specific resources (e.g.: axon.html)
     * /PATH_AXON_API/raw-sensor-data       serves current sensor data (check below for more info)
     * /PATH_AXON_API/historic-sensor-data  serves sensor data from a timespan (check below for more info)
     */
    
    
    //TODO: new path mapping, implement in axons?
    let PATH_AXON_API = "nervousnet-api"
    
    private func mapAxonHTTPServerRoutes(){
        
        // route to list available services
        self.server["/"] = { r in
            var listPage = "<div style='font-family: Helvetica; font-size: 12pt'>Available nervousnet services on this device:<br><ul>"
            for services in self.server.routes {
                if !services.isEmpty {
                    listPage += "<li><a href=\"\(services)\">\(services)</a></li>"
                }
            }
            listPage += "</ul></div>"
            return .ok(.html(listPage))
        }
        
        
        // route to get static resources like JS, HTML or assets provided by nervous
        self.server.GET["/nervousnet-axon-resources/:resource"] = { request in
            //want: axon-res/static/:resource
            
            if let filename = request.params[":resource"] {
                return self.returnRawResponse("\(self.axonResourceDir)\(filename)");
            }
            return .notFound

        }
        
        
        // route to get any axon resource
        self.server.GET["/axon-res/:axonname/:resource"] = { request in
            //want: axon-res/:axonname/:resource
            if let filename = request.params[":resource"], let axonname = request.params[":axonname"] {
                return self.returnRawResponse("\(self.axonDir)/\(axonname)/\(axonname)-master/\(filename)");
            }
            return .notFound

        }
        
        
        
        // route to get current sensor data
        ///
        /// URL:                /\(PATH_AXON_API)/raw-sensor-data
        /// query parameter:    axon (String)
        /// e.g.: localhost:8080/axon-api/raw-sensor-data?axon=gps
        ///
        self.server.GET["/\(PATH_AXON_API)/raw-sensor-data/:name"] = { request in
            //want: axon-api/raw-sensor-data/
            
            
            if let axon = request.params[":name"] {

                do {
                    let dataDict = try self.getSensorDataFor(axon: axon)
                    
                    //log.info("serving request from axon \(axon)")
                    return .ok(.json(dataDict))
                } catch {
                    //log.error(error.localizedDescription)
                    return .internalServerError
                }
                
            }
            
            /*
            if let axon = self.parseRawRequest(queryParams: request.queryParams) {
                
                let dataDict = self.getSensorDataFor(axon: axon)
                
                return .ok(.json(dataDict))

            }
            */
            
            return .badRequest(.text("Querry parameters badly formated"))
            
        }
        
        
        // route to get historic sensor data
        ///
        /// URL:                /\(PATH_AXON_API)//historic-sensor-data"
        /// query parameter:    axon (String), 
        ///                     start (convertible to UInt64), 
        ///                     end (convertible to UInt64)
        /// e.g.: localhost:8080/axon-api/historic-sensor-data?axon=gps&start=1&end=5
        ///
        self.server.GET["/\(PATH_AXON_API)/historic-sensor-data"] = { request in
            
            if let paramValues = self.parseHistoricRequest(queryParams: request.queryParams) {
                
                do {
                    let dataDict = try self.getSensorDataFor(axon: paramValues.axon, start: paramValues.start, end: paramValues.end)

                    return .ok(.json(dataDict))
                } catch ASCError.UnknownSensorName {
                    return .badRequest(.text("The requested sensor Name is not available"))
                } catch {
                    log.error(error.localizedDescription)
                    return .internalServerError
                }
            }
            
            return .badRequest(.text("Querry parameters badly formated"))
        }
        
    }
    
    
    
    /* write the http response */
    private func returnRawResponse(_ fileURL:String) -> HttpResponse {
        
        if let contentsOfFile = NSData(contentsOfFile: fileURL) {
            log.debug("getting \(fileURL)")

            var contentsOfFileBytes = [UInt8](repeating: 0, count: contentsOfFile.length)
            contentsOfFile.getBytes(&contentsOfFileBytes, length: contentsOfFile.length)
            
            return HttpResponse.raw(200, "OK", nil, { try $0.write(contentsOfFileBytes) })
        }
        
        log.error("resource at \(fileURL) not found")
        return .notFound
        
    }
    
    
    
    //unwrap query params and return axon name if the parameter name matches
    private func parseRawRequest(queryParams : [(String, String)] ) -> String? {
        
        guard let tuple = queryParams.first else {
            log.error("Bad raw request parameters")
            return nil
        }
        
        if tuple.0 == "axon" {
            return tuple.1
        }
        
        return nil
    }
    
    
    
    private func parseHistoricRequest(queryParams : [(String, String)] ) -> (axon: String, start: Int64, end: Int64)? {

        if queryParams.count != 3 {
            log.error("Bad historic request with no parameters")
            return nil
        }
        
        var axon = "", s = "", e = ""
        
        for tuple in queryParams {
            switch tuple.0 {//query param name
                case "axon":
                    axon = tuple.1
                case "start":
                    s = tuple.1
                case "end":
                    e = tuple.1
            default:
                log.error("Bad historic request with unexpected parameters")
                return nil //we expect no other parameter names
            }
        }
        
        if let start = Int64(s, radix: 10), let end = Int64(e, radix: 10) {
            if(start > end) {
                log.error("Start time is after end time")
                return nil
            }
            
            return (axon, start, end)

        } else {
            log.error("Error parsing time vales (should be a String convertable to microseconds)")
            return nil
        }
        
    }
    
    
    
    private func getSensorDataFor(axon: String, start: Int64, end: Int64) throws -> NSArray {
        
        var result = [NSDictionary]()
        
        guard let sensorID = nVM.sensorNameToID[axon] else {
            log.error("Error. The sensor \"\(axon)\" seems to have no configuration and therefore sensorID is unknown. Cannot retrieve data.")
            throw ASCError.UnknownSensorName
        }

        //we made sure previously that start < end, safely retrieve historic sensor data
        let readingList = try nVM.getReadings(sensorID: sensorID, start: start, end: end)
        
        var singleReadingResult = [String : Any]()
        
        for reading in readingList {
            for (name, _) in reading.parameterNameToType {
                singleReadingResult[name] = reading.getValue(paramName: name)
            }
            result.append(singleReadingResult as NSDictionary)
        }
        
        return result as NSArray
    }
    
    private func getSensorDataFor(axon: String) throws -> NSDictionary {
        
        var singleReadingResult = [String : Any]()

        guard let sensorID = nVM.sensorNameToID[axon] else {
            log.error("Error. The sensor \"\(axon)\" seems to have no configuration and therefore sensorID is unknown. Cannot retrieve data.")
            throw ASCError.UnknownSensorName
        }
        
        
        let reading = try nVM.getLatestReading(sensorID: sensorID)
        
        for (name, _) in reading.parameterNameToType {
            singleReadingResult[name] = reading.getValue(paramName: name)
        }
        
        return singleReadingResult as NSDictionary
    }
    
    
    
    enum ASCError : Error {
        case UnknownSensorName
    }
    
}

