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
		
		_cfg = Config()
		_cfg?.loadPlayList()
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
		Item.text = _cfg!.PlayList[ind].address
		self.separatorInset.left = 0
	}
}

