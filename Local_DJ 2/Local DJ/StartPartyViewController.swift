//
//  StartPartyViewController.swift
//  Local DJ
//
//  Created by Kirill Kudaev on 2/21/16.
//  Copyright © 2016 Jami Wissman, Kirill Kudaev. All rights reserved.
//

import UIKit
import Parse

class StartPartyViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var mytextField: UITextField!
    @IBOutlet var mySwitch: UISwitch!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mytextField.delegate = self
        self.mytextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startPressed(sender: AnyObject) {
        
        if (mytextField.text != "") {
            var party = PFObject(className:"Parties")
            party["name"] = mytextField.text
            if mySwitch.on {
                party["private"] = true
            } else {
                party["private"] = false
            }
            party.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    // The object has been saved.
                } else {
                    // There was a problem, check error.description
                }
            }
            
            performSegueWithIdentifier("partyStarted", sender: self)
        } else {
            
            let alertController = UIAlertController(title: "Oops!", message:
                "Please enter name for your party", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }


    
    // Close keyboard when touched outside.
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Close keyboard when "return" is touched.
    func textFieldShouldReturn(textfield: UITextField) -> Bool {
        mytextField.resignFirstResponder()
        return true
    }
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        if (segue.identifier == "partyStarted") {
            var mq = segue.destinationViewController as! MusicQueueTableViewController
            mq.partyName = mytextField.text!
        }
        
    }

}
