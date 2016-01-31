//
//  ProfileVC.swift
//  Hierarchy
//
//  Created by hiso on 2015/06/03.
//  Copyright (c) 2015年 祐輔 花田. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import iAd

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let ud = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postformTextfield: UITextField!
    @IBOutlet var tableView : UITableView?
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var block_button: UIButton!
    
    var refreshControl : UIRefreshControl!
    
    override func viewDidLoad() {
        //self.canDisplayBannerAds = true
        
        block_button.setTitle("BLOCK", forState: .Normal)
        for item in block_users {
            if item == ud.stringForKey("selected_id")! {
                block_button.setTitle("UNBLOCK", forState: .Normal)
            }
        }
        
        self.tableView!.estimatedRowHeight = 80
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        
        nameLabel.text = "Hello, I'm " + ud.stringForKey("name")!
        
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
            let parameters: [String: AnyObject] = [
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
        print(data.count-indexPath.row-1)
        let text: String = data[data.count-indexPath.row-2]["parent_hierarchy"].string!
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
        
        let params : [String:AnyObject!] =
        [
            "id" : ud.stringForKey("selected_id")
        ]
        
        Alamofire.request(.GET, url, parameters: params)
            .responseJSON { (res) in
                if(res.result.error != nil) {
                    NSLog("Error: \(res.result.error)")
                    print(res)
                    
                    let alert = UIAlertView()
                    alert.title = "Connection Error"
                    alert.message = ""
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    
                }
                else {
                    NSLog("Success: \(url)\n")
                    self.data = (JSON(res.result.value!))
                    print(self.data)
                    //println(self.data[0]["contents"])
                    self.tableView!.reloadData()
                    
                    let red = CGFloat( NSString(string: self.data[self.data.count-1]["red"].string!).floatValue )
                    let green = CGFloat( NSString(string: self.data[self.data.count-1]["green"].string!).floatValue )
                    let blue = CGFloat( NSString(string: self.data[self.data.count-1]["blue"].string!).floatValue )
                    
                    self.navigationController?.navigationBar.barTintColor = UIColor(red:1.0-red, green:1.0-green, blue:1.0-blue, alpha: 1.0)
                    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red:red, green:green, blue:blue, alpha: 1.0)]
                    self.navigationController?.navigationBar.tintColor = UIColor(red:red, green:green, blue:blue, alpha: 1.0)
                    
                    let imgnum = NSString(string: self.data[self.data.count-1]["image_num"].string!).intValue
                    let url = NSURL(string: baseurl+"/get_image/\(imgnum)")
                    var err: NSError?
                    let imageData :NSData = NSData(contentsOfURL: url!)!
                    let img = UIImage(data:imageData)
                    self.userImageView.image = img
                    
                    self.nameLabel.text = "Hello, I'm " + self.data[self.data.count-1]["name"].string!
                }
                
                /*
                self.connectcount++
                if(self.connectcount>20){
                exit(0)
                }
                */
        }
    }
    
    @IBAction func block_pushed(sender: AnyObject) {
        print(block_button.titleLabel?.text)
        let id = ud.stringForKey("selected_id")!
        
        if block_button.titleLabel?.text == "BLOCK"{
            block_button.setTitle("UNBLOCK", forState: .Normal)
            
            block_users.append(ud.stringForKey("selected_id")!)
            ud.setObject(block_users, forKey: "block_users")
            
        }else if block_button.titleLabel?.text == "UNBLOCK" {
            block_button.setTitle("BLOCK", forState: .Normal)
            
            for var i = 0; i < block_users.count; i++ {
                if block_users[i] == id {
                    block_users.removeAtIndex(i)
                }
            }
            ud.setObject(block_users, forKey: "block_users")
        }
        
        print(block_users)
    }
    
    
}