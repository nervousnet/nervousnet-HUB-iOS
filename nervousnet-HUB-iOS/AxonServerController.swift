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
    
    var server = HttpServer()
    
    let axonResourceDir = "\(Bundle.main.resourcePath!)/Assets/axon-resources/"
    let axonDir = "\(NSHomeDirectory())/Documents/nervousnet-installed-axons/"
    //let laeController = LAEController() TODO: connect to sensor data layer
    
    var pseudoSensorData: Int = 0

    init(){
        startAxonHTTPServer()
        
        //TODO: remove automatic download of axon, only for testing while UI missing
        AxonStore.getRemoteAxonList() //needs to be loaded first
        if AxonStore.downloadAndInstall(axonIndex: 0) {
            log.debug("Downloaded axon-one successfully for testing")
        } else {
            log.debug("Failed to download axon-one for testing")
        }
    }
    
    
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
    
    let PATH_AXON_API = "axon-api"
    let PATH_AXON_RES = "axon-res"
    
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
        self.server.GET["/\(PATH_AXON_RES)/static/:resource"] = { request in
            
            if let filename = request.params[":resource"] {
                return self.returnRawResponse("\(self.axonResourceDir)\(filename)");
            }
            return .notFound

        }
        
        
        // route to get any axon resource
        self.server.GET["/\(PATH_AXON_RES)/:axonname/:resource"] = { request in
            if let filename = request.params[":resource"], let axonname = request.params[":axonname"] {
                return self.returnRawResponse("\(self.axonDir)/\(axonname)/\(axonname)-master/\(filename)");
            }
            return .notFound

        }
        
        
        
        // route to get current sensor data
        self.server.GET["/\(PATH_AXON_API)/raw-sensor-data"] = { request in
            
            if let axon = self.parseRawRequest(queryParams: request.queryParams) {
                
                let dataDict = self.getSensorDataFor(axon: axon)
                
                return .ok(.json(dataDict))

            }
            
            return .badRequest(.text("Querry parameters badly formated"))
            
        }
        
        
        // route to get historic sensor data
        self.server.GET["/\(PATH_AXON_RES)/historic-sensor-data"] = { request in
            
            if let paramValues = self.parseHistoricRequest(queryParams: request.queryParams) {
                
                let dataDict = self.getSensorDataFor(axon: paramValues.axon, start: paramValues.start, end: paramValues.end)

                return .ok(.json(dataDict))

            }
            
            return .badRequest(.text("Querry parameters badly formated"))
        }
        
    }
    
    
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
    
    private func parseHistoricRequest(queryParams : [(String, String)] ) -> (axon: String, start: UInt64, end: UInt64)? {

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
                case "stop":
                    e = tuple.1
            default:
                log.error("Bad historic request with unexpected parameters")
                return nil //we expect no other parameter names
            }
        }
        
        if let start = UInt64(s, radix: 10), let end = UInt64(e, radix: 10) {
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
    
    
    private func getSensorDataFor(axon: String, start: UInt64 = 0, end: UInt64 = 0) -> NSDictionary {
        
        if(start == end) {// get current sensor data
            
        } else { //we made sure previously that start < end, safely retrieve historic sensor data
            
        }
        
        //TODO connect above if clause to actual sensor layer, convert to json
        pseudoSensorData += 1
        return ["data": pseudoSensorData]
    }
    
    
}

