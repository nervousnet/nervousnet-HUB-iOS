//
//  AppDelegate.swift
//  nervousnet-HUB-iOS
//
//  Created by prasad on 21/09/16.
//  Copyright © 2016 ETH Zurich - COSS. All rights reserved.
//

import UIKit
import XCGLogger
import Parse

let log = XCGLogger.default

let nVM = VM.sharedInstance

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let axonController = AxonServerController()
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        log.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, fileLevel: .debug)

        AxonStore.installLocalIncludedAxons()
        
        let configuration = ParseClientConfiguration {
            $0.applicationId = "nervousnet"
            $0.server = "http://207.154.242.197:1337/parse"
            $0.isLocalDatastoreEnabled = true
        }
        Parse.initialize(with: configuration)
        
        
        //The nVM.run is only a dummy method there to ensure that nVM is initialzed asap
        //Since nVM.sharedInstance is a static variable and swift lazily initializes static variables
        //this would not happen if we do not trigger lazy initialization with a call to run()
        //This could be changed by a better initialization of VM()
        nVM.run()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

