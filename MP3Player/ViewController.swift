//
//  ViewController.swift
//  MP3Player
//
//  Created by Yuri Romanov on 18.06.15.
//  Copyright (c) 2015 yurirom. All rights reserved.
//

import UIKit
import AVFoundation

var audioPlayer: AVAudioPlayer?

class ViewController: UITableViewController
{
	var bRefreshing = false
	@IBOutlet weak var deleteButton: UIBarButtonItem!
	
	@IBAction func deleteFiles(sender: AnyObject)
	{
		var fileExists = false
		let title = "Внимание!"
		let message = "Загруженные файлы будут удалены!\nВы уверены?"
		let cancelButtonTitle = "Cancel"
		let otherButtonTitle = "OK"
		
		let alertCotroller = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		
		let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
			return
		}
		
		let otherAction = UIAlertAction(title: otherButtonTitle, style: .Default) { action in
			let paths: NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
			let documentsDirectory: NSString = paths.objectAtIndex(0) as! NSString
			var fileExists = false
			
			for i in 0..<_cfg!.PlayList.count
			{
				_cfg!.PlayList[i].checked = false
				self.tableView.reloadData()
				if !_cfg!.PlayList[i].fname.isEmpty
				{
					fileExists = NSFileManager.defaultManager().fileExistsAtPath(documentsDirectory.stringByAppendingPathComponent(_cfg!.PlayList[i].fname))
				}
				if fileExists
				{
					NSFileManager.defaultManager().removeItemAtPath(documentsDirectory.stringByAppendingPathComponent(_cfg!.PlayList[i].fname), error: nil)
					self.refresh()
				}
			}
		}
		
		// Add the actions.
		alertCotroller.addAction(cancelAction)
		alertCotroller.addAction(otherAction)
		
		presentViewController(alertCotroller, animated: true, completion: nil)
	}
	
	override func viewDidLoad()
	{
		super.viewDidLoad()
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
		self.refreshControl?.tintColor = UIColor.blackColor()
		deleteButton.enabled = false
		self.navigationItem.title = "Playlist"

		_cfg = Config()
		_cfg?.loadPlayList()
	}

    override func viewDidAppear(animated: Bool)
    {
        refresh()
    }

	func refresh()
	{
		if bRefreshing
		{
			self.refreshControl?.endRefreshing()
			return
		}
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		let paths: NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
		let documentsDirectory: NSString = paths.objectAtIndex(0) as! NSString
		var fileExists = false
		deleteButton.enabled = false
		
		for i in 0..<_cfg!.PlayList.count
		{
			_cfg!.PlayList[i].checked = false
			self.tableView.reloadData()
			if !_cfg!.PlayList[i].fname.isEmpty
			{
				fileExists = NSFileManager.defaultManager().fileExistsAtPath(documentsDirectory.stringByAppendingPathComponent(_cfg!.PlayList[i].fname))
			}
			if !fileExists
			{
				dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), {self.loadFile(i)})
			}
			else
			{
				_cfg!.PlayList[i].checked = true
				deleteButton.enabled = true
				let furl = NSURL(fileURLWithPath: documentsDirectory.stringByAppendingPathComponent(_cfg!.PlayList[i].fname))!
				_cfg!.PlayList[i].meta = loadMetaDataFromAudioFile(furl)
				self.tableView.reloadData()
				self.tableView.setNeedsDisplay()
			}
		}
		self.refreshControl?.endRefreshing()
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false
	}
	
	func loadFile(ind: Int)
	{
		bRefreshing = true
		let paths: NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
		let documentsDirectory: NSString = paths.objectAtIndex(0) as! NSString
		
		var url: NSURL = NSURL(string: _cfg!.PlayList[ind].address)!
		var data = NSData(contentsOfURL: url, options: .DataReadingUncached, error: nil)
		if data != nil
		{
			let path = documentsDirectory.stringByAppendingPathComponent(_cfg!.PlayList[ind].fname)
			data!.writeToFile(path, atomically: true)
			_cfg!.PlayList[ind].checked = true
			deleteButton.enabled = true
			let furl = NSURL(fileURLWithPath: documentsDirectory.stringByAppendingPathComponent(_cfg!.PlayList[ind].fname))!
			_cfg!.PlayList[ind].meta = loadMetaDataFromAudioFile(furl)
			self.tableView.reloadData()
			self.tableView.setNeedsDisplay()
		}
		bRefreshing = false
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Table View Data Source
	// MARK: -
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return _cfg!.PlayList.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let CellIdentifier = "Cell"
		let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath:indexPath) as! ItemCell
		cell.SetItem(indexPath.row)
		cell.backgroundColor = UIColor.whiteColor()
		if indexPath.row == selectedItem
		{
			cell.contentView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1)
		}
		return cell
	}
	
	// MARK: - Table View Delegate
	// MARK: -
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		let bstop = selectedItem == indexPath.row
		selectedItem = indexPath.row
		tableView.reloadData()
		if bstop && audioPlayer != nil
		{
			audioPlayer = nil
		}
		else
		{
			let paths: NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
			let documentsDirectory: NSString = paths.objectAtIndex(0) as! NSString
			var data = NSData(contentsOfFile: documentsDirectory.stringByAppendingPathComponent(_cfg!.PlayList[selectedItem].fname))
			Player(data!)
		}
	}
}

// MARK: - none Class Functions
// MARK: -
func clearURL(str: String) -> String
{
	return str.stringByReplacingOccurrencesOfString("%20", withString: " ", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil).stringByReplacingOccurrencesOfString("%28", withString: "(", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil).stringByReplacingOccurrencesOfString("%29", withString: ")", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
}

func Player(D: NSData)
{
	if audioPlayer != nil
	{
		audioPlayer = nil
	}
	var e = NSErrorPointer()
	audioPlayer = AVAudioPlayer(data: D, error: e)
	audioPlayer?.prepareToPlay()
	if let sound = audioPlayer
	{
		sound.play()
	}
}

func loadMetaDataFromAudioFile(url: NSURL) -> MetaData
{
	let asset: AVAsset = AVURLAsset(URL:url, options: nil)
	let meta: Array = asset.commonMetadata
	let md = MetaData()
	
	for item in meta
	{
		switch item.commonKey as String
		{
		case AVMetadataCommonKeyTitle:
			md.title = item.stringValue
		case AVMetadataCommonKeyAlbumName:
			md.album = item.stringValue
		case AVMetadataCommonKeyArtist:
			md.artist = item.stringValue
		case AVMetadataCommonKeyArtwork:
			md.artwork = UIImage(data:item.dataValue)
		default:
			break
		}
	}
	return md
}

// MARK: - Class ItemCell
// MARK: -
class ItemCell: UITableViewCell
{
	@IBOutlet weak var Item: UILabel!
	@IBOutlet var grayIndicator: UIActivityIndicatorView!
	
	func SetItem(ind: Int)
	{
		self.contentView.backgroundColor = UIColor.whiteColor()
		grayIndicator.activityIndicatorViewStyle = .Gray
		grayIndicator.hidesWhenStopped = true
		self.separatorInset.left = 2000
		
		if _cfg!.PlayList[ind].checked
		{
			Item.text = "Title: \(_cfg!.PlayList[ind].meta.title)  Artist: \(_cfg!.PlayList[ind].meta.artist)"
			grayIndicator.stopAnimating()
			self.contentView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.97, alpha: 1.0)
			self.separatorInset.left = 0
		}
		else
		{
			Item.text = clearURL(_cfg!.PlayList[ind].address)
			grayIndicator.startAnimating()
		}
	}
}
