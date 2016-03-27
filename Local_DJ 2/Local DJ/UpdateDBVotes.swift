//
//  UpdateDBVotes.swift
//  Local DJ
//
//  Created by Kirill Kudaev on 3/26/16.
//  Copyright © 2016 Jami Wissman. All rights reserved.
//

import UIKit
import Parse

class UpdateDBVotes: NSObject {
    
    func addNewSong(partyName: String, xxxx: AnyObject)
    {
        var votesTable = PFObject(className:"Votes")
        votesTable["partyName"] = partyName
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
    
}
