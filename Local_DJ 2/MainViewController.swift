//
//  MainViewController.swift
//  Local DJ
//
//  Created by Jami Wissman on 2/18/16.
//  Copyright © 2016 Jami Wissman, Kirill Kudaev. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var ProfileImageView: UIImageView!
    @IBOutlet weak var UserNameLabel: UILabel!
    
    var session = globalSession
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        SPTUser.requestCurrentUserWithAccessToken(session.accessToken) { (error:NSError!, user:AnyObject!) -> Void in
            let currentUser:SPTUser = user as! SPTUser
            self.UserNameLabel.text = currentUser.displayName
            
            
            if let profileImage:SPTImage = currentUser.smallestImage{
                if let url = profileImage.imageURL {
                    if let data = NSData(contentsOfURL: url) {
                        self.ProfileImageView.image = UIImage(data: data)
                    }
                    
                }
            }
        }
        
        self.ProfileImageView.layer.masksToBounds = true
        self.ProfileImageView.layer.cornerRadius = 64
    }

    @IBAction func StartAParty(sender: AnyObject) {
    }
    
    @IBAction func JoinAParty(sender: AnyObject) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
