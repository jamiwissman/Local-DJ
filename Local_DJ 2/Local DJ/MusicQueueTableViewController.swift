//
//  MusicQueueTableViewController.swift
//  Local DJ
//
//  Created by Jami Wissman on 1/27/16.
//  Copyright © 2016 Jami Wissman, Kirill Kudaev. All rights reserved.
//

import UIKit
import Parse

class MusicQueueTableViewController: UITableViewController,  SPTAudioStreamingPlaybackDelegate, UISearchBarDelegate {
    
    let clientID = "6be42602926140ffbedb14f2d2f4029b"
    
    var partyName = "No party name"
    var songQueue: Array<AnyObject> = []
    var songNumber:UInt!
    var session = globalSession
    var player:SPTAudioStreamingController!
    var featuredPlaylists:SPTFeaturedPlaylistList!
    var addSong:Bool = false
    var spotifySearchBar:UISearchBar!
    var searchActive: Bool = false
    var numSearchResults:Int = 0
    var searchResultsList: Array<AnyObject> = []
    var musicPaused:Bool = false
    
    let playlistURI = NSURL(string: "spotify:user:spotify:playlist:4hOKQuZbraPDIfaGbM3lKI")
    

    
    @IBOutlet weak var AddSongContainerView: UIView!

    @IBAction func playSongButton(sender: AnyObject) {
        if (musicPaused == false){
            playUsingSession(session)
        }
        else{
            self.player.setIsPlaying(true) { (error:NSError!) -> Void in
                if (error != nil)
                {
                    print("Error pausing music")
                }
                self.musicPaused = false
            }

        }
    }

    @IBAction func nextSongButton(sender: AnyObject) {
        playNext()
    }
   
    @IBAction func pauseSongButton(sender: AnyObject) {
        self.player.setIsPlaying(false) { (error:NSError!) -> Void in
            if (error != nil)
            {
                print("Error pausing music")
            }
            self.musicPaused = true
        }
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.tableView.reloadData()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if addSong == false{
            return songQueue.count + 1
        }
        else if searchActive == false {return 2}
        else {return 2+numSearchResults}
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if addSong == false{
            if indexPath.row == 0 {
                let cellID:NSString = "PlayCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellID as String, forIndexPath: indexPath) as! PlayMusicTableViewCell
                
                cell.partyNameLabel.text = partyName
                
                return cell
            }
            else{
                let cellID:NSString = "SongCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellID as String, forIndexPath: indexPath) as! SongTableViewCell
                
                cell.songTitleLabel.text = self.songQueue[indexPath.row - 1].name
                var artistsArray:Array<AnyObject> = self.songQueue[indexPath.row - 1].artists
                cell.songArtistLabel.text = artistsArray[0].name
                
                let album:SPTPartialAlbum = self.songQueue[indexPath.row - 1].album
                let albumArt:SPTImage = album.smallestCover
                
                if let url = albumArt.imageURL {
                    if let data = NSData(contentsOfURL: url) {
                        
                        cell.songAlbumCoverImageView.image = UIImage(data: data)
                    }
                }

                
                cell.upButton.tag = indexPath.row
                cell.downButton.tag = indexPath.row
                
                cell.upButton.addTarget(self, action: #selector(MusicQueueTableViewController.upVote(_:)), forControlEvents: .TouchUpInside)
                cell.downButton.addTarget(self, action: #selector(MusicQueueTableViewController.downVote(_:)), forControlEvents: .TouchUpInside)
                

                return cell
            }

        }
        else if searchActive == false{
            if indexPath.row == 0 {
                let cellID:NSString = "PlayCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellID as String, forIndexPath: indexPath) as! PlayMusicTableViewCell
                return cell
            }
            else{
                let cellID:NSString = "SearchCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellID as String, forIndexPath: indexPath) as! SearchTableViewCell
                spotifySearchBar = cell.SpotifySearchBar
                spotifySearchBar.delegate = self
                return cell
            }
        }
        else{
            
            if indexPath.row == 0 {
                let cellID:NSString = "PlayCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellID as String, forIndexPath: indexPath) as! PlayMusicTableViewCell
                return cell
            }
            if indexPath.row == 1 {
                let cellID:NSString = "SearchCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellID as String, forIndexPath: indexPath) as! SearchTableViewCell
                spotifySearchBar = cell.SpotifySearchBar
                return cell
            }
            else{
                let cellID:NSString = "AddSongCell"
                let cell = tableView.dequeueReusableCellWithIdentifier(cellID as String, forIndexPath: indexPath) as! SongTableViewCell
                
                cell.songTitleLabel.text = self.searchResultsList[indexPath.row - 2].name
                var artistsArray:Array<AnyObject> = self.searchResultsList[indexPath.row - 2].artists
                cell.songArtistLabel.text = artistsArray[0].name
                
                let album:SPTPartialAlbum = self.searchResultsList[indexPath.row - 2].album
                let albumArt:SPTImage = album.smallestCover
                
                if let url = albumArt.imageURL {
                    if let data = NSData(contentsOfURL: url) {
                        cell.songAlbumCoverImageView.image = UIImage(data: data)
                    }
                }
                cell.addSongToQueueButton.tag = indexPath.row
                
                return cell
            }

        }
    }
    
    
    // In order to delete rows.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete && addSong == false && indexPath.row != 0 {
            // Delete the row from the data source
            songQueue.removeAtIndex(indexPath.row - 1)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    
    
    func playUsingSession(sessionObj:SPTSession!){
        if player == nil {
            player = SPTAudioStreamingController(clientId: clientID)
        }
        
        player?.loginWithSession(sessionObj, callback: { (error:NSError!) -> Void in
            if error != nil {
                print("Enabling playback error \(error)")
                return
            }
            
                
            for track:SPTPartialTrack in self.songQueue as! [SPTPartialTrack]{
                self.player.queueURI(track.playableUri, clearQueue: false, callback: { (error:NSError!) -> Void in
                    if (error != nil){
                        print("Error queueing playlist \(error)")
                        return
                    }
                })
            }
            
            
            self.player.queuePlay({ (error:NSError!) -> Void in
                if(error != nil){
                    print("Error playing queue \(error)")
                    return
                }
            })
        })
    }
    
    func playNext(){
        if player == nil {
            player = SPTAudioStreamingController(clientId: clientID)
        }
        self.player.skipNext { (error:NSError!) -> Void in
            if (error != nil){
                print("Error playing next song \(error)")
                return
            }
        }
    }
    
    @IBAction func upVote(sender: AnyObject?){
    
        
        print(songQueue)
        
        let tag:NSInteger = sender!.tag
        let indexPath = NSIndexPath(forRow: tag, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SongTableViewCell
        
        if cell.voted == "no" {
            
            cell.voted = "up"
            
            // Select up button.
            cell.upButton.setImage(UIImage(named:"Arrow Up Green.png"), forState: UIControlState.Normal)
            
        } else if cell.voted == "down" {
            
            cell.voted = "up"
            
            // Unselect down button.
            cell.downButton.setImage(UIImage(named:"Arrow Down White.png"), forState: UIControlState.Normal)
            
            // Select up button.
            cell.upButton.setImage(UIImage(named:"Arrow Up Green.png"), forState: UIControlState.Normal)
            
        } else if cell.voted == "up" {
             // If already selected and pressed - unselect
            
            cell.voted = "no"
            
            // Unselect up button.
            cell.upButton.setImage(UIImage(named:"Arrow Up White.png"), forState: UIControlState.Normal)
        }
        
        
//        If we have more than one section we need this:
//        let position:CGPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
//        if let indexPath = self.tableView.indexPathForRowAtPoint(position) {
//        
//            let section = indexPath.section
//            let row = indexPath.row
//            let indexPath = NSIndexPath(forRow: row, inSection: section)
//            let cell = tableView.cellForRowAtIndexPath(indexPath) as! SongTableViewCell
//            cell.songTitleLabel.textColor = UIColor.greenColor()
//        }
        
        // Needs work
//        let temp = songQueue[sender.tag - 1]
//        songQueue[sender.tag - 1] = songQueue[sender.tag]
//        songQueue[sender.tag] = temp
//        self.tableView.reloadData()
        
         }
    
    
    @IBAction func downVote(sender: AnyObject?){
        
        
        let tag:NSInteger = sender!.tag
        let indexPath = NSIndexPath(forRow: tag, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SongTableViewCell
        
    
        if cell.voted == "no" {
            
            cell.voted = "down"
            
            // Select up button.
            cell.downButton.setImage(UIImage(named:"Arrow Down Red.png"), forState: UIControlState.Normal)
            
        } else if cell.voted == "up" {
            
            cell.voted = "down"
            
            // Unselect up button.
            cell.upButton.setImage(UIImage(named:"Arrow Up White.png"), forState: UIControlState.Normal)
            
            // Select down button.
            cell.downButton.setImage(UIImage(named:"Arrow Down Red.png"), forState: UIControlState.Normal)
            
        } else if cell.voted == "down" {
            // If already selected and pressed - unselect
            
            cell.voted = "no"
            
            // Unselect down button.
            cell.downButton.setImage(UIImage(named:"Arrow Down White.png"), forState: UIControlState.Normal)
            
        }
        
//        If we have more than one section we need this:
//        let position:CGPoint = sender.convertPoint(CGPointZero, toView: self.tableView)
//        if let indexPath = self.tableView.indexPathForRowAtPoint(position) {
//
//            let section = indexPath.section
//            let row = indexPath.row
//            let indexPath = NSIndexPath(forRow: row, inSection: section)
//            let cell = tableView.cellForRowAtIndexPath(indexPath) as! SongTableViewCell
//            cell.songTitleLabel.textColor = UIColor.greenColor()
//        }
    }
    
    
    
    @IBAction func AddSongButton(sender: AnyObject) {
        addSong = true
        self.tableView.reloadData()
    }
    @IBAction func AddSongToQueueButton(sender: AnyObject) {
        addSong = false
        searchActive = false
        let itemNum:Int = sender.tag - 2
        songQueue.append(searchResultsList[itemNum])
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = true
        SPTSearch.performSearchWithQuery(searchBar.text, queryType: SPTSearchQueryType.QueryTypeTrack, accessToken: session.accessToken) { (error:NSError!, results:AnyObject!) -> Void in
            let searchResults = results as! SPTListPage
            
            self.searchResultsList = searchResults.items
            self.numSearchResults = self.searchResultsList.count
            self.tableView.reloadData()
        }
    }
    
    func audioStreaming(audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: NSURL!) {
        //code for when track starts playing
    }

}
