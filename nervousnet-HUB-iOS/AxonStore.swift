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

    private static let includedAxonDir = "\(Bundle.main.resourcePath!)/Assets/included-axons/"
    private static let remoteAxonTestingRepo = "https://api.github.com/repos/nervousnet/nervousnet-axons/contents/testing?ref=master"
    private static let remoteAxonRepoZipSuffix = "/archive/master.zip"
    private static let installedAxonsDir = "\(NSHomeDirectory())/Documents/nervousnet-installed-axons"
    private static let singleAxonRootURL = "http://localhost:8080/nervousnet-axons"
    private static let axonIndexFile = "axon.html"

    private static var remoteAxonList = Array<AxonDetails>()
    private static let localDefaultAxons = Constants.PREINSTALLED_AXON_NAMES
    static private var lastFetched = NSDate().timeIntervalSince1970
    static private let updateInterval = 3600.0 //seconds
    
    
    //now it gets really ugly, blacklisted axons by name as used on github axon repository
    //https://github.com/nervousnet/nervousnet-axons/tree/master/testing
    //TODO: at least move this into a file, or do something cleverer
    // (issue ticket: https://github.com/nervousnet/nervousnet-HUB-iOS/issues/19)
    static private let blacklistedAxons = ["axon-acctest",
                                           //"axon-graph",
                                           "axon-lewin",
                                           "axon-one",
                                           "axon-pat",
                                           "axon-prasad",
                                           "axon-sid",
                                           "axon-survive",
                                           "axon-traveasy",
                                           //"delta-kit-logger",
                                           "my-town"]
    
    
    class func getInstalledAxonsList() -> Array<AxonDetails>{
        var installedAxons = Array<AxonDetails>()
        let filemanager:FileManager = FileManager()
        let files = filemanager.enumerator(atPath: installedAxonsDir)
        
        while let file = files?.nextObject() {
            if((file as AnyObject).hasSuffix("/package.json")){
                let appPackageJSON = JSON(data: NSData(contentsOfFile: "\(installedAxonsDir)/\(file)")! as Data)
                
                let axonDetails = AxonDetails(name: appPackageJSON["name"].string!,
                                              title: appPackageJSON["title"].string!,
                                              description: appPackageJSON["description"].string!,
                                              icon: appPackageJSON["icon"].string!)
                
                installedAxons.append(axonDetails)
            }
        }
        
        return installedAxons
    }
    

    class func isAxonInstalled(axonName: String) -> Bool {
        return getInstalledAxonsList().contains(where: { axon -> Bool in
            return axon.name == axonName
        })
    }

    
    //Need to copy the default axons from the app bundle into the appropriate install location
    class func installLocalIncludedAxons() {
        
        for name in localDefaultAxons {
            // the '-master' postfix is required due to the AxonServer expecting this naming convention
            let sourcePath = "\(self.includedAxonDir)\(name)-master"
            let destPath = "\(self.installedAxonsDir)/\(name)"

            do {
                if !FileManager.default.fileExists(atPath: destPath) {
                    try FileManager.default.createDirectory(at: URL(fileURLWithPath: destPath), withIntermediateDirectories: true, attributes: nil)
                    log.debug("creating dest directory was successful")
                    
                    
                    let destDirectory = "\(destPath)/\(name)-master"
                    try FileManager.default.copyItem(atPath: sourcePath, toPath: destDirectory)
                    log.info("Local axon \(name) successfully installed")
                }
            }
            catch { log.error("Unable to install local default axon because of \(error.localizedDescription)")}
            
        }
    }
    
    
    
    class func downladAndInstall(axonName: String) -> Bool {
        let index = self.getRemoteAxonIndexByName(axonName: axonName)
        return downloadAndInstall(axonIndex: index)
    }
    
    
    
    // download axon in a blocking fashion
    class func downloadAndInstall(axonIndex: Int) -> Bool {
    
        let axon = getRemoteAxon(axonIndex: axonIndex)
        
        //Get documents directory URL
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        
        
        let urlPath = axon.repository_url! + remoteAxonRepoZipSuffix //TODO: handle missing repo_url
        
        let sourceUrl = NSURL(string: urlPath)!
        
        
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
            let axonName = axon.name
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
            
            log.info("succesfully installed \(axonName) axon")
            return true
            
        }
        catch let err as NSError {
            log.error(err)
            log.error("Something went wrong")
            
            return false
        }
    }
    



    private class func getRemoteAxonIndexByName(axonName: String) -> Int {
        fetchRemoteAxonList()
        for (index,_) in remoteAxonList.enumerated() {
            
            if(self.remoteAxonList[index].name == axonName){
                return index
            }
            
        }
        
        return -1
    }


    class func getRemoteAxon(axonIndex: Int) -> AxonDetails {
        //FIXME: handle invalid index
        fetchRemoteAxonList()
        return remoteAxonList[axonIndex]
    }

    
    class func getLocalAxon(axonIndex: Int) -> AxonDetails {
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
    
    
    
    class func getRemoteAxonList() -> Array<AxonDetails> {
        fetchRemoteAxonList()
        return remoteAxonList
    }
    
    
    
    //blocking task
    private class func fetchRemoteAxonList() {
        log.debug("DOWNLOADING")
        let current_ts = NSDate().timeIntervalSince1970
        let valid_until_ts = lastFetched + updateInterval
        
        guard remoteAxonList.isEmpty || (current_ts > valid_until_ts) else { //basic caching
            return
        }
        
        let endpoint = NSURL(string: remoteAxonTestingRepo)
        
        var resultList = Array<AxonDetails>()

        if let data = NSData(contentsOf: endpoint! as URL) {

            let json = JSON(data: data as Data);
            
            //get the individual package details by going through the jsons in the repo
            for (_,axon_metadata) in json{
                
                let axon_json_url = NSURL(string: axon_metadata["download_url"].stringValue)
                let axon_json = NSData(contentsOf: axon_json_url! as URL)
                let axon = JSON(data: axon_json! as Data);
                let axonDetails = AxonDetails(name:             axon["name"].stringValue,
                                              title:            axon["title"].stringValue,
                                              description:      axon["description"].stringValue,
                                              icon:             axon["icon"].stringValue,
                                              repository_url:   axon["repository"]["url"].stringValue,
                                              author:           axon["author"].stringValue)
                if !blacklistedAxons.contains(axonDetails.name) {
                    resultList.append(axonDetails)
                }
            }
        }else{
            log.error("cannot download remote axon list")
        }
        
        lastFetched = current_ts
        remoteAxonList = resultList
        log.debug("DOWNLOADED")
    }

}


struct AxonDetails {
    public let name,
    title,
    description,
    icon : String
    public private(set) var repository_url,
    author : String?
    
    init(name : String, title : String, description : String, icon : String) {
        
        self.name = name
        self.title = title
        self.description = description
        self.icon = icon
    }
    
    init(name : String, title : String, description : String, icon : String,
         repository_url : String, author : String) {
        
        self.name = name
        self.title = title
        self.description = description
        self.icon = icon
        self.repository_url = repository_url
        self.author = author
    }
}

