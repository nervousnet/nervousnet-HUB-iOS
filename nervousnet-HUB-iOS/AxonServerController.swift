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
        if AxonStore.downloadAndInstall(axonIndex: 3) {
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
    
    
    func mapAxonHTTPServerRoutes(){
        
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
        self.server.GET["/nervousnet-axon-resources/:resource"] = { r in
            if let filename = r.params[":resource"] {
                return self.returnRawResponse("\(self.axonResourceDir)\(filename)");
            }
            return .notFound

        }
        
        
        // route to get any axon resource
        self.server.GET["/nervousnet-axons/:axonname/:resource"] = { r in
            if let filename = r.params[":resource"], let axonname = r.params[":axonname"] {
                return self.returnRawResponse("\(self.axonDir)/\(axonname)/\(axonname)-master/\(filename)");
            }
            return .notFound

        }
        
        
        
        // route to get any axon resource
        self.server.GET["/nervousnet-api/raw-sensor-data/:sensor/"] = { r in
            
            if let _ = r.params[":sensor"] {
                
                
                self.pseudoSensorData += 1
                let data =  self.pseudoSensorData

                
                let jsonObject: NSDictionary = ["data": data]
                return .ok(.json(jsonObject))
                
                
                
                //TODO change this to fit together with new data layer as proposed by Alex
                
                /*
                let data =  self.laeController.getData(sensor)
                
                print(data)
                if(sensor == "BLE"){
                    let jsonObject: NSDictionary = ["blepacket": data[0] as! String]
                    return .OK(.Json(jsonObject))
                }else if(sensor == "GPS"){
                    let jsonObject: NSDictionary = ["lat": data[0], "long":data[1]]
                    return .OK(.Json(jsonObject))
                }else{
                    let jsonObject: NSDictionary = ["x": data[0], "y":data[1], "z": data[2]]
                    return .OK(.Json(jsonObject))

                }
                */
 
            }
            
            return .notFound
            
        }
        
        
    }
    
    
    func returnRawResponse(_ fileURL:String) -> HttpResponse {
        
        if let contentsOfFile = NSData(contentsOfFile: fileURL) {
            log.debug("getting \(fileURL)")

            var contentsOfFileBytes = [UInt8](repeating: 0, count: contentsOfFile.length)
            contentsOfFile.getBytes(&contentsOfFileBytes, length: contentsOfFile.length)
            
            return HttpResponse.raw(200, "OK", nil, { try $0.write(contentsOfFileBytes) })
        }
        
        log.error("resource at \(fileURL) not found")
        return .notFound
        
    }
    
    
}

