//
//  SearchTableViewCell.swift
//  Local DJ
//
//  Created by Jami Wissman on 2/25/16.
//  Copyright © 2016 Jami Wissman. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var SpotifySearchBar: UISearchBar!
    var searchText:String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //let searchText = SpotifySearchBar.text
    }

}
