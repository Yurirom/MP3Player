//
//  Classes.swift
//  MP3Player
//
//  Created by Yuri Romanov on 18.06.15.
//  Copyright (c) 2015 yurirom. All rights reserved.
//

import UIKit

// MARK: - Global variables
// MARK: -

var _cfg: Config?
var selectedItem = 0

// MARK: - Config
// MARK: -
class Config
{
	var PlayListAdr: String = String()
	var PlayList: [PlayItem] = []
	
	init()
	{
		let path = NSBundle.mainBundle().pathForResource("Config", ofType: "txt")
		var content = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)
		
		if content != nil
		{
			let str = content!.componentsSeparatedByString("\n")
			PlayListAdr = str[0]
		}
	}
	
	func loadPlayList()
	{
		if !PlayListAdr.isEmpty
		{
			let url: NSURL = NSURL(string: PlayListAdr)!
			var content = String(contentsOfURL: url, encoding: NSUTF8StringEncoding, error: nil)
			
			if content != nil
			{
				let str = content!.componentsSeparatedByString("\n")
				for s in str
				{
					let clearS = s.stringByReplacingOccurrencesOfString("\r", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
					let clearExt = clearS.pathExtension.componentsSeparatedByString("?")[0]
					if clearExt == "mp3"
					{
						var newItem = PlayItem()
						newItem.address = clearS
						let xfile = clearURL(clearS).componentsSeparatedByString("?")[0]
						let clearFileName = xfile.lastPathComponent
						newItem.fname = clearFileName
						PlayList.append(newItem)
					}
				}
			}
		}
	}
}

// MARK: - PlayItem
// MARK: -
struct PlayItem
{
	var address: String = String()
	var meta: MetaData = MetaData()
	var fname: String = String()
	var checked: Bool = false
}

// MARK: - MetaData
// MARK: -
class MetaData
{
	var title: String = String()
	var artist: String = String()
	var album: String = String()
	var artwork: UIImage?
}

