//
//  ViewController.swift
//  Local DJ
//
//  Created by Jami Wissman on 1/26/16.
//  Copyright © 2016 Jami Wissman, Kirill Kudaev. All rights reserved.
//

import UIKit


var globalSession:SPTSession!

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    
    let clientID = "6be42602926140ffbedb14f2d2f4029b"
    let redirectURL = "Local-DJ://returnAfterLogin"
    let tokenSwapURL = "http://localhost:1234/swap"
    let tokenRefreshURL = "http://localhost:1234/refresh"
    
    var session:SPTSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.updateAfterFirstLogin), name: "loginSuccessful", object: nil)
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession"){ //session available
            let sessionDataObj = sessionObj as! NSData
            session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataObj) as! SPTSession
            globalSession = session
            let auth = SPTAuth.defaultInstance()
            
            if !session.isValid(){ // If session is no longer valid
                print("Session not valid")
                if auth.hasTokenRefreshService{
                    print("has service")
                    auth.renewSession(self.session, callback: { (error:NSError!, renewedSession:SPTSession!) -> Void in
                        if error == nil {
                            let sessionData = NSKeyedArchiver.archivedDataWithRootObject(self.session)
                            userDefaults.setObject(sessionData, forKey: "SpotifySession")
                            userDefaults.synchronize()
                            self.session = renewedSession
                        }
                    })
                    self.performSegueWithIdentifier("loginSuccessful", sender: self)
                }
                else {
                    print("no service")
                    loginWithSpotify(self)
                }
            }
                
            else{ // If session is valid, segue
                self.performSegueWithIdentifier("loginSuccessful", sender: self)
            }
            
        }
        else{
            loginButton.hidden = false
            
        }

    }
    func updateAfterFirstLogin () {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let sessionObj:AnyObject = userDefaults.objectForKey("SpotifySession"){ //session available
            let sessionDataObj = sessionObj as! NSData
            session = NSKeyedUnarchiver.unarchiveObjectWithData(sessionDataObj) as! SPTSession
            globalSession = session
            
            self.performSegueWithIdentifier("loginSuccessful", sender: self)
        }

    }

    @IBAction func loginWithSpotify(sender: AnyObject) {
        let auth = SPTAuth.defaultInstance()
        
        auth.clientID = clientID
        auth.redirectURL = NSURL(string: redirectURL)
        auth.requestedScopes = [SPTAuthStreamingScope]
        auth.tokenRefreshURL = NSURL(string: tokenRefreshURL)
        
        let loginURL = auth.loginURL
        sleep(1)
        UIApplication.sharedApplication().openURL(loginURL)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if (segue.identifier == "loginSuccessful"){
//            let mainVC = segue.destinationViewController as! MainViewController
//            mainVC.session = self.session
//        }
//    }



}

