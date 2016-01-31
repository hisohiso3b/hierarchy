//
//  RootTVC.swift
//  Hierarchy
//
//  Created by hiso on 2015/06/02.
//  Copyright (c) 2015年 祐輔 花田. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import iAd

let end_num = 2000

class RootTVC: UITableViewController {
    
    let ud = NSUserDefaults.standardUserDefaults()
    var connectcount = 0
    
    //array of entries
    var entries = JSON("")
    
    override func viewDidLoad() {
        //self.canDisplayBannerAds = true
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.863, green:0.078, blue:0.235, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        reload(self)
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl!.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
    }
    
    override func viewDidAppear(animated: Bool) {
        ud.setObject("/", forKey: "selected_path")
        //reload(self)
        super.viewDidAppear(animated)
        
        //var temp :Float = Float(entries.count) * Float(50.0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //count cell of table view
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //println("row is \(entries.count)")
        return entries.count
    }
    
    //make tableView
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //get cell
        let cell = tableView.dequeueReusableCellWithIdentifier("HierarchyCell", forIndexPath: indexPath) //UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: "user")
        
        /*
        var randr : Float = randFloat(Min: 0.7, Max: 0.9)
        var randg : Float = randFloat(Min: 0.7, Max: 0.9)
        var randb : Float = randFloat(Min: 0.7, Max: 0.9)
        var cellcolor = UIColor(red:CGFloat(randr), green:CGFloat(randg), blue:CGFloat(randb), alpha:1.0)
        cell.backgroundColor = cellcolor
        */
        
        //var randg : Float = randFloat(Min: 0.7, Max: 0.9)
        let cellcolor = UIColor(
            red:CGFloat(0.9+0.002 * Float(indexPath.row%50)),
            green:CGFloat(1.0),
            blue:CGFloat(1 - 0.002 * Float(indexPath.row%50)),
            alpha:1.0)
        cell.backgroundColor = cellcolor
        
        //get entry
        var entry = entries[entries.count-indexPath.row-1]// as! NSDictionary
        
        //set title
        cell.textLabel!.text = entry["contents"].string!
        cell.detailTextLabel?.text = entry["name"].string
        //cell.detailTextLabel?.text = cell.detailTextLabel!.text! + "Phone:" + entry["phone"].string!
        
        return cell
    }
    
    func refresh(){
        reload(self)
        self.refreshControl!.endRefreshing()
    }
    
    //reload
    @IBAction func reload(sender: AnyObject) {
        
        let url = baseurl + "/path_get"
        
        let params : [String:AnyObject!] =
        [
            "parents_hierarchy" : "/"
        ]
        
        Alamofire.request(.GET, url, parameters: params).responseJSON { (res) in
                if(res.result.error != nil) {
                    //NSLog("Error: \(error)")
                    //println(req)
                    print(res)
                    
                    let alert = UIAlertView()
                    alert.title = "Connection Error"
                    alert.message = ""
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    
                }
                else {
                    NSLog("Success: \(url)\n")
                    self.entries = (JSON(res.result.value!))
                    print(self.entries)
                    print(self.entries[0]["contents"])
                    self.tableView.reloadData()
                }
                
                self.connectcount++
                if(self.connectcount>end_num){
                    exit(0)
                }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Num: \(indexPath.row)")
        //println("Value: \(entries[indexPath.row])")
        
        ud.setObject(entries[entries.count-indexPath.row-1]["my_hierarchy"].string!, forKey: "selected_path")
        
        /*
        ud.setInteger(entries[entries.count-indexPath.row-1]["id"].int!, forKey: "selected_todo_id")
        ud.setObject(entries[entries.count-indexPath.row-1]["content"].string, forKey: "selected_title")
        ud.setObject(entries[entries.count-indexPath.row-1]["message"].string, forKey: "selected_message")
        */

        /*
        var nex : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("RangeContents")
        //self.presentViewController(nex as! UIViewController, animated: true, completion: nil)
        self.navigationController!.pushViewController(nex as! UIViewController, animated: true)
        */
    }
    
    @IBAction func post_pushed(sender: AnyObject) {
        ud.setObject("/", forKey: "selected_path")
    }
    
    func randFloat(Min _Min : Float, Max _Max : Float)->Float {
        
        return ( Float(arc4random_uniform(UINT32_MAX)) / Float(UINT32_MAX) ) * (_Max - _Min) + _Min
    }
    
    
    /*
    //
    //swipe menu
    //
    override func tableView(tableView: UITableView,canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            //arr.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?  {
        // 1
        var shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Profile" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            // 2
            /*
            let shareMenu = UIAlertController(title: nil, message: "Share using", preferredStyle: .ActionSheet)
            
            let twitterAction = UIAlertAction(title: "Twitter", style: UIAlertActionStyle.Default, handler: nil)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            shareMenu.addAction(twitterAction)
            shareMenu.addAction(cancelAction)
            
            
            self.presentViewController(shareMenu, animated: true, completion: nil)
            */
            println("GoProfile")
        })
        // 3
        var rateAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "☆" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            /*
            // 4
            let rateMenu = UIAlertController(title: nil, message: "Rate this App", preferredStyle: .ActionSheet)
            
            let appRateAction = UIAlertAction(title: "Rate", style: UIAlertActionStyle.Default, handler: nil)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            rateMenu.addAction(appRateAction)
            rateMenu.addAction(cancelAction)
            
            
            self.presentViewController(rateMenu, animated: true, completion: nil)
            */
            let favMenu = UIAlertController(title: nil, message: "Favorited", preferredStyle: .ActionSheet)
            let favAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            favMenu.addAction(favAction)
            println("faved")
            self.presentViewController(favMenu, animated: true, completion: nil)
            
        })
        // 5
        return [shareAction,rateAction]
    }
    */
}