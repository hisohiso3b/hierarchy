//
//  SecondViewController.swift
//  Hierarchy
//
//  Created by hiso on 2015/06/02.
//  Copyright (c) 2015年 祐輔 花田. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let ud = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postformTextfield: UITextField!
    @IBOutlet var tableView : UITableView?
    @IBOutlet weak var userImageView: UIImageView!
    
    var refreshControl : UIRefreshControl!
    
    override func viewDidLoad() {
        
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.863, green:0.078, blue:0.235, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        self.tableView!.estimatedRowHeight = 80
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        
        nameLabel.text = "Hello, " + ud.stringForKey("name")!
        
        tableView!.delegate = self
        tableView!.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl!.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView!.addSubview(refreshControl!)
        
        reloadData()
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pushSend(sender: AnyObject) {
        if(postformTextfield.text != ""){
            let parameters : [String: AnyObject] = [
                "name": ud.stringForKey("name")!,
                "id": ud.stringForKey("id")!,
                "contents": postformTextfield.text!,
                "my_hierarchy": "/"+postformTextfield.text!,
                "parent_hierarchy": "/"
            ]
            
            Alamofire.request(.POST, baseurl + "/post_message", parameters: parameters, encoding: .JSON)
            print("posted")
            
            /*
            Alamofire.request(.GET, "http://httpbin.org/get")
                .responseString { (_, _, string, _) in
                    println(string)
                }
                .responseJSON { (_, _, JSON, _) in
                    println(JSON)
            }
            */
            
        }
    }
    
    @IBAction func tapScreen(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    
    //
    //tableView settings
    //
    var data: JSON = JSON("")
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        return data.count - 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Title", forIndexPath: indexPath) 
        
        cell.textLabel?.text = data[data.count-indexPath.row-1 - 1]["my_hierarchy"].string!
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        var text: String = data[data.count-indexPath.row-2]["parent_hierarchy"].string!
        print(text)
        
        ud.setObject(text, forKey: "selected_path")
        
        let next: UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PathTVC") 
        self.navigationController!.pushViewController(next as UIViewController, animated: true)
    }
    
    //
    //GET data source
    //
    func refresh(){
        reloadData()
        self.refreshControl!.endRefreshing()
    }
    
    func reloadData(){
        let url = baseurl + "/id_get"
        
        var params : [String:AnyObject!] =
        [
            "id" : ud.stringForKey("id")
        ]
        
        Alamofire.request(.GET, url, parameters: params)
            .responseJSON { (res) in
                if(res.result.error != nil) {
                    NSLog("Error: \(res.result.error)")
                    print(res.result.value)
                    
                    var alert = UIAlertView()
                    alert.title = "Connection Error"
                    alert.message = ""
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    
                } else {
                    NSLog("Success: \(url)\n")
                    self.data = (JSON(res.result.value!))
                    print(self.data)
                    
                    //println(self.data[0]["contents"])
                    self.tableView!.reloadData()
                    self.nameLabel.text = self.ud.stringForKey("name")
                    
                    print(NSString(string: self.data[self.data.count-1]["red"].string!).floatValue)
                    
                    
                    var red = CGFloat( NSString(string: self.data[self.data.count-1]["red"].string!).floatValue )
                    var green = CGFloat( NSString(string: self.data[self.data.count-1]["green"].string!).floatValue )
                    var blue = CGFloat( NSString(string: self.data[self.data.count-1]["blue"].string!).floatValue )
                    
                    self.navigationController?.navigationBar.barTintColor = UIColor(red:1.0-red, green:1.0-green, blue:1.0-blue, alpha: 1.0)
                    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red:red, green:green, blue:blue, alpha: 1.0)]
                    self.navigationController?.navigationBar.tintColor = UIColor(red:red, green:green, blue:blue, alpha: 1.0)
                    
                    var imgnum = NSString(string: self.data[self.data.count-1]["image_num"].string!).intValue
                    let url = NSURL(string: baseurl+"/get_image/\(imgnum)")
                    var err: NSError?
                    var imageData :NSData = NSData(contentsOfURL: url!)!
                    var img = UIImage(data:imageData)
                    self.userImageView.image = img

                    //let base64 = (self.data[self.data.count-1]["image"].rawData())!
                    //self.userImageView.image = UIImage(data: base64)
                    
                }
                
                /*
                self.connectcount++
                if(self.connectcount>20){
                    exit(0)
                }
                */
        }
    }
    
    
    /*
    //removecell
    
    func tableView(tableView: UITableView,canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return true
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            //arr.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?  {
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
            println("Shared")
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



