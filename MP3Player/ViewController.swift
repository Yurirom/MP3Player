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
		self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
		self.refreshControl?.tintColor = UIColor.blackColor()

		_cfg = Config()
		_cfg?.loadPlayList()
	}

//    override func viewDidAppear(animated: Bool)
//    {
//        Update()
//    }

//    override func viewWillTransitionToSize(size: CGSize,
//        withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator)
//    {
//        var x = DW
//        DW = DH
//        DH = x
//        Offset = DW / 6
////        Update()
//    }

	func refresh(sender:AnyObject)
	{
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		refreshtab()
		self.refreshControl?.endRefreshing()
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false
	}
	
	func refreshtab()
	{
		
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

// MARK: - Class ItemCell
// MARK: -
class ItemCell: UITableViewCell
{
	@IBOutlet weak var Item: UILabel!
//	@IBOutlet weak var Image: UIImageView!
	
	func SetItem(ind: Int)
	{
//		var img = UIImage(named: _cfg!.Menu[ind] + ".png")
//		if img == nil
//		{
//			img = UIImage(named: "nopic.png")
//		}
//		MenuImage.image = img
//		MenuImage.backgroundColor = _cfg!.Colors[3].c
		let fixs = _cfg!.PlayList[ind].address.stringByReplacingOccurrencesOfString("%20", withString: " ", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil).stringByReplacingOccurrencesOfString("%28", withString: "(", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil).stringByReplacingOccurrencesOfString("%29", withString: ")", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
		Item.text = fixs
		self.separatorInset.left = 0
	}
}

