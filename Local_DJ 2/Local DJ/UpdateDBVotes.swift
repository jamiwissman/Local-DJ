//
//  UpdateDBVotes.swift
//  Local DJ
//
//  Created by Kirill Kudaev on 3/26/16.
//  Copyright © 2016 Jami Wissman, Kirill Kudaev. All rights reserved.
//

import UIKit
import Parse

class UpdateDBVotes: NSObject {
    
    func addNewSong(partyName: String, uri: String)
    {
        let votesTable = PFObject(className:"Votes")
        votesTable["partyName"] = partyName
        votesTable["uri"] = uri
        votesTable["rating"] = 0


        votesTable.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
            } else {
                // There was a problem, check error.description
            }
        }
    }
    
    func deleteSong(partyName: String, uri: String)
    {
        
        let query = PFQuery(className: "Votes")
        query.whereKey("partyName", equalTo: partyName)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            for object in objects! {
                object.deleteEventually()
            }
        }
    }
    
    func changeRatingBy(partyName: String, uri: String, num: Int)
    {
        let query = PFQuery(className: "Votes")
        query.whereKey("partyName", equalTo: partyName)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            for object in objects! {
                object.incrementKey("rating", byAmount: num)
                object.saveInBackground()
            }
        }

        
    }
    
}
