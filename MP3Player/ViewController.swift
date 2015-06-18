//
//  ViewController.swift
//  MP3Player
//
//  Created by Yuri Romanov on 18.06.15.
//  Copyright (c) 2015 yurirom. All rights reserved.
//

import UIKit

class ViewController: UITableViewController
{
	override func viewDidLoad()
	{
		super.viewDidLoad()
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
		self.refreshControl?.tintColor = UIColor.blackColor()
		
		_cfg = Config()
		_cfg?.loadPlayList()
	}

    override func viewDidAppear(animated: Bool)
    {
        refresh()
    }

	func refresh()
	{
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		let paths: NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
		let documentsDirectory: NSString = paths.objectAtIndex(0) as! NSString
		var fileExists = false
		
		for i in 0..<_cfg!.PlayList.count
		{
			if !_cfg!.PlayList[i].fname.isEmpty
			{
				fileExists = NSFileManager.defaultManager().fileExistsAtPath(documentsDirectory.stringByAppendingPathComponent(_cfg!.PlayList[i].fname))
			}
			if _cfg!.PlayList[i].fname.isEmpty || !fileExists
			{
				loadFile(i)
			}
		}
		self.refreshControl?.endRefreshing()
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false
	}
	
	func loadFile(ind: Int)
	{
		let paths: NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
		let documentsDirectory: NSString = paths.objectAtIndex(0) as! NSString
		
		var url: NSURL = NSURL(string: _cfg!.PlayList[ind].address)!
		var data = NSData(contentsOfURL: url, options: .DataReadingUncached, error: nil)
		if data != nil
		{
			let xfile = clearURL(_cfg!.PlayList[ind].address).componentsSeparatedByString("?")[0]
			let clearFileName = xfile.lastPathComponent
			_cfg!.PlayList[ind].fname = clearFileName
			let path = documentsDirectory.stringByAppendingPathComponent(clearFileName)
			data!.writeToFile(path, atomically: true)
			self.tableView.reloadData()
		}
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
			cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1)
		}
		return cell
	}
	
	// MARK: - Table View Delegate
	// MARK: -
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		selectedItem = indexPath.row
		tableView.reloadData()
	}
}

// MARK: - none Class Functions
// MARK: -
func clearURL(str: String) -> String
{
	return str.stringByReplacingOccurrencesOfString("%20", withString: " ", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil).stringByReplacingOccurrencesOfString("%28", withString: "(", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil).stringByReplacingOccurrencesOfString("%29", withString: ")", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
}

// MARK: - Class ItemCell
// MARK: -
class ItemCell: UITableViewCell
{
	@IBOutlet weak var Item: UILabel!
	@IBOutlet var grayIndicator: UIActivityIndicatorView!
//	@IBOutlet weak var Image: UIImageView!
	
	// When activity is done, use UIActivityIndicatorView.stopAnimating().
	
	func SetItem(ind: Int)
	{
		//		var img = UIImage(named: _cfg!.Menu[ind] + ".png")
//		if img == nil
//		{
//			img = UIImage(named: "nopic.png")
//		}
//		MenuImage.image = img
//		MenuImage.backgroundColor = _cfg!.Colors[3].c
		if _cfg!.PlayList[ind].fname.isEmpty
		{
			Item.text = clearURL(_cfg!.PlayList[ind].address)
			grayIndicator.activityIndicatorViewStyle = .Gray
			grayIndicator.startAnimating()
			grayIndicator.hidesWhenStopped = true
		}
		else
		{
			Item.text = _cfg!.PlayList[ind].fname
			grayIndicator.stopAnimating()
		}
	}
}

