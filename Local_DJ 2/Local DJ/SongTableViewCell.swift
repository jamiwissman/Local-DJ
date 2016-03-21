//
//  SongTableViewCell.swift
//  Local DJ
//
//  Created by Jami Wissman on 1/27/16.
//  Copyright © 2016 Jami Wissman. All rights reserved.
//

import UIKit

class SongTableViewCell: UITableViewCell {
    
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songAlbumCoverImageView: UIImageView!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var addSongToQueueButton: UIButton!
    
    // Holds user vote. Can be no, up or down.
    var voted = "no"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
