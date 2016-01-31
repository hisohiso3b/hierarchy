//
//  FavsTVC.swift
//  Hierarchy
//
//  Created by hiso on 2015/06/02.
//  Copyright (c) 2015年 祐輔 花田. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import iAd
import DZNEmptyDataSet

class FavsTVC: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    let ud = NSUserDefaults.standardUserDefaults()
    var connectcount = 0
    var here: String = "/"
    
    //array of entries
    var entries: [String] = []//JSON("")
    
    override func viewDidLoad() {
        //self.canDisplayBannerAds = true
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.863, green:0.078, blue:0.235, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        //self.canDisplayBannerAds = true
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        //ud.setObject(self.title, forKey: "selected_path")
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        if ud.stringArrayForKey("favs") != nil {
            entries = ud.stringArrayForKey("favs")!
        }
        self.tableView.reloadData()
        
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //count cell of table view
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("row is \(entries.count)")
        return entries.count
    }
    
    //make tableView
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //get cell
        let cell = tableView.dequeueReusableCellWithIdentifier("Title", forIndexPath: indexPath) 
        
        //get entry
        let entry = entries[entries.count-indexPath.row-1] 
        
        cell.textLabel?.lineBreakMode
        cell.textLabel!.text = entry
        cell.layoutIfNeeded()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Num: \(indexPath.row)")
        //println("Value: \(entries[indexPath.row])")
        
        ud.setObject(entries[entries.count-indexPath.row-1], forKey: "selected_path")
        
        let next: UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PathTVC") 
        self.navigationController!.pushViewController(next as UIViewController, animated: true)
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            entries.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            
            ud.setObject(entries, forKey: "favs")
        }
    }
    
    @IBAction func postPushed(sender: AnyObject) {
        ud.setObject(here, forKey: "selected_path")
        
    }
    
    //empty data set
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "お気に入りは0件です\n\n投稿を左へスワイプすることで投稿をお気に入り出来ます."
        let font = UIFont(name: "ヒラギノ角ゴ ProN", size: 20)!
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: font])
    }
}