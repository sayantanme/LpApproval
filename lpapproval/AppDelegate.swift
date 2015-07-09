//
//  AppDelegate.swift
//  lpapproval
//
//  Created by Sayantan Chakraborty on 26/06/15.
//  Copyright (c) 2015 Sayantan Chakraborty. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        IMFClient.sharedInstance().initializeWithBackendRoute("https://lpapproval.mybluemix.net", backendGUID: "ab94b10c-0fa5-4368-b63e-43b8e613fc89")
        
        IMFLogger.captureUncaughtExceptions()
        IMFLogger.setLogLevel(IMFLogLevel.Info)
        IMFAnalytics.sharedInstance().startRecordingApplicationLifecycleEvents()
        
        var logger : IMFLogger = IMFLogger(forName: "AppDelegate")
        logger.logInfoWithMessages("Test")
        IMFLogger.send()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        IMFLogger.send()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

