//
//  AppDelegate.swift
//  Local DJ
//
//  Created by Jami Wissman on 1/26/16.
//  Copyright © 2016 Jami Wissman, Kirill Kudaev. All rights reserved.
//

import UIKit
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let clientID = "6be42602926140ffbedb14f2d2f4029b"
    let redirectURL = "Local-DJ://returnAfterLogin"
    let tokenSwapURL = "http://localhost:1234/swap"
    let tokenRefreshURL = "http://localhost:1234/refresh"
    
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios/guide#local-datastore
        Parse.enableLocalDatastore()
        
        // Initialize Parse.
        Parse.setApplicationId("HQpPYaKvVAMDw9RU3YnOesGOEQLe3vZuKPIoSvKg",
            clientKey: "5In4F9oDYTSOjSQ3zl987cs2YwZ1l0KSiE1H4zWs")
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
       return true
    }

    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {


        
        
        if SPTAuth.defaultInstance().canHandleURL(NSURL(string: redirectURL))
        {
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: { (error:NSError!, session:SPTSession!) -> Void in
                if error != nil
                {
                    print("Authentication error")
                    return
                }
                
                // Save Spotify session to be able to work with it
                let userDefaults = NSUserDefaults.standardUserDefaults() //like a dictionary to store user info
                let sessionData = NSKeyedArchiver.archivedDataWithRootObject(session)
                userDefaults.setObject(sessionData, forKey: "SpotifySession")
                userDefaults.synchronize()
                print ("Session saved")
            
                
                //Notification for login successful
                NSNotificationCenter.defaultCenter().postNotificationName("loginSuccessful", object: nil)
            })
            
        }
        else{
            print("can handle URL error")
        }
        return false
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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

