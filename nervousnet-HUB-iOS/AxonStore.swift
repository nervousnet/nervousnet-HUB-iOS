//
//  AxonStore.swift
//  nervousnet-iOS
//  
//  Created by Sam Sulaimanov on 03 Mar 2016.
//  Copyright (c) 2016 ETHZ . All rights reserved.
//


import Foundation
import SwiftyJSON
import Zip

///
/// Axon Store gets Axon information from the local disk.
///
class AxonStore : NSObject {

    static let includedAxonDir = "\(Bundle.main.resourcePath)/Assets/included-axons/"
    static let remoteAxonTestingRepo = "https://api.github.com/repos/nervousnet/nervousnet-axons/contents/testing?ref=master"
    static let remoteAxonRepoZipSuffix = "/archive/master.zip"
    static let installedAxonsDir = "\(NSHomeDirectory())/Documents/nervousnet-installed-axons"
    static let singleAxonRootURL = "http://localhost:8080/nervousnet-axons"
    static let axonIndexFile = "axon.html"

    static var remoteAxonList = Array<Array<String>>()
    static private var lastFetched = NSDate().timeIntervalSince1970 //TODO: apparently in seconds, check
    static private let updateInterval = 3600.0 //seconds
    
    
    
    class func getInstalledAxonsList() -> Array<Array<String>>{
        var installedAxons = Array<Array<String>>()
        let filemanager:FileManager = FileManager()
        let files = filemanager.enumerator(atPath: installedAxonsDir)
        
        while let file = files?.nextObject() {
            if((file as AnyObject).hasSuffix("/package.json")){
                let appPackageJSON = JSON(data: NSData(contentsOfFile: "\(installedAxonsDir)/\(file)")! as Data)
                
                let arrayOfStrings: [String] = [appPackageJSON["name"].string!, appPackageJSON["title"].string!, appPackageJSON["description"].string!, appPackageJSON["icon"].string!];
                
                installedAxons.append(arrayOfStrings)
            }
        }
        
        return installedAxons
    }
    
    
    
    // download axon in a blocking fashion
    class func downloadAndInstall(axonIndex: Int) -> Bool {
    
        let axon = getRemoteAxon(axonIndex: axonIndex)
        
        //Get documents directory URL
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let sourceUrl = NSURL(string: "\(axon[4])/\(remoteAxonRepoZipSuffix)")!
        
        
        //Get the file name and create a LOCAL destination URL
        let fileName = sourceUrl.lastPathComponent!
        let destinationURL = documentsDirectory!.appendingPathComponent(fileName)
        
        //Hold this file as an NSData and write it to the new location
        if let fileData = NSData(contentsOf: sourceUrl as URL) {
            fileData.write(to: destinationURL, atomically: false)   // true
            log.debug(destinationURL.path)
        }else{
            log.error("couldn't download repo zip")
            return false
        }
        
        
        do {
            let axonName = axon[0]
            let axonZipFile = destinationURL
            let unzipDirectory = try Zip.quickUnzipFile(axonZipFile) // Unzip
            
            do {
                try fileManager.createDirectory(atPath: installedAxonsDir, withIntermediateDirectories: true, attributes: nil);
            } catch let err as NSError {
                log.error(err)
                log.error("install dir already exists, not creating")
                
                return false

            }
            
            do {
                try fileManager.moveItem(atPath: unzipDirectory.path, toPath: "\(installedAxonsDir)/\(axonName)")
            } catch let err as NSError {
                log.error(err)
                log.error("unable to move axon to install path")
                
                return false

            }
            
            
            return true
            
        }
        catch let err as NSError {
            log.error(err)
            log.error("Something went wrong")
            
            return false
        }
        

    }
    



    class func getRemoteAxonIndexByName(axonName: String) -> Int {
        fetchRemoteAxonList()
        for (index,_) in remoteAxonList.enumerated() {
            
            if(self.remoteAxonList[index][0] == axonName){
                return index
            }
            
        }
        
        return -1
        
    }


    class func getRemoteAxon(axonIndex: Int) -> Array<String> {
        fetchRemoteAxonList()
        return remoteAxonList[axonIndex]
    }

    
    class func getLocalAxon(axonIndex: Int) -> Array<String> {
        return getInstalledAxonsList()[axonIndex]
    }

    
    class func getLocalAxonURL(axonName: String) -> NSURL? {
        let url = NSURL(string: "\(singleAxonRootURL)/\(axonName)/\(axonIndexFile)")
        return url
    }
    
    class func removeLocalAxon(axonName: String) -> Bool {
        let path =  "\(installedAxonsDir)/\(axonName)"
        let fileManager = FileManager.default

        //DELETE SUBFOLDER
        do {
            try fileManager.removeItem(atPath: path)
            return true
        }
        catch let error as NSError {
            log.error("An error occured while removing axon: \(error)")
        }
        
        return false
        
    }
    
    
    
    class func getRemoteAxonList() -> Array<Array<String>> {
        fetchRemoteAxonList()
        return remoteAxonList
    }
    
    
    
    //blocking task
    private class func fetchRemoteAxonList() {
        
        let current_ts = NSDate().timeIntervalSince1970
        let valid_until_ts = lastFetched + updateInterval
        
        guard remoteAxonList.isEmpty || (current_ts > valid_until_ts) else { //basic caching
            return
        }
        
        let endpoint = NSURL(string: remoteAxonTestingRepo)
        var resultList = Array<Array<String>>()

        if let data = NSData(contentsOf: endpoint! as URL) {

            let json = JSON(data: data as Data);
            
            //get the individual package details by going through the jsons in the repo
            for (_,axon_metadata) in json{
                
                let axon_json_url = NSURL(string: axon_metadata["download_url"].stringValue)
                let axon_json = NSData(contentsOf: axon_json_url! as URL)
                let axon = JSON(data: axon_json! as Data);
                let arrayOfStrings: [String] = [axon["name"].stringValue, axon["title"].stringValue, axon["description"].stringValue, axon["icon"].stringValue, axon["repository"]["url"].stringValue, axon["author"].stringValue]
                resultList.append(arrayOfStrings)
            }
        }else{
            log.error("cannot download remote axon list")
        }
        
        lastFetched = current_ts
        remoteAxonList = resultList
    }

}

