//
//  PostVC.swift
//  Hierarchy
//
//  Created by hiso on 2015/06/02.
//  Copyright (c) 2015年 祐輔 花田. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PostVC: UIViewController {
    let ud = NSUserDefaults.standardUserDefaults()
    
    //@IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postformTextfield: UITextField!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var permittionAttention: UILabel!
    
    override func viewDidLoad() {
        
        for item in req_permittion_dir {
            if ud.stringForKey("selected_path")! == item{
                var permittion = false
                for id in masterID {
                    if id == ud.stringForKey("id") {
                        permittion = true
                        print("permit")
                    }
                }
                
                if !permittion {
                    postButton.enabled = false;
                    permittionAttention.text = "you don't have permittion"
                }
            }
        }
        
        //nameLabel.text = "Hello, " + ud.stringForKey("name")!
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pushSend(sender: AnyObject) {
        if(
            postformTextfield.text != "" &&
            postformTextfield.text!.utf16.count < 300
            ){
            var parameters: [String: AnyObject!]
            
            if ud.stringForKey("selected_path")! != "/"{
                parameters = [
                    "name": ud.stringForKey("name")!,
                    "id": ud.stringForKey("id")!,
                    "contents": postformTextfield.text,
                    "my_hierarchy": ud.stringForKey("selected_path")!+"/"+postformTextfield.text!,
                    "parent_hierarchy": ud.stringForKey("selected_path"),
                    "image_num": ud.integerForKey("image_num"),
                    "red": ud.floatForKey("red"),
                    "green": ud.floatForKey("green"),
                    "blue": ud.floatForKey("blue")
                ]
            }else{
                parameters = [
                    "name": ud.stringForKey("name")!,
                    "id": ud.stringForKey("id")!,
                    "contents": postformTextfield.text,
                    "my_hierarchy": ud.stringForKey("selected_path")!+postformTextfield.text!,
                    "parent_hierarchy": "/",
                    "image_num": ud.integerForKey("image_num"),
                    "red": ud.floatForKey("red"),
                    "green": ud.floatForKey("green"),
                    "blue": ud.floatForKey("blue")
                ]
            }
            
            print(parameters)
            
            Alamofire.request(.POST, baseurl + "/post_message", parameters: parameters, encoding: .JSON)
            
            print("posted")
            self.navigationController?.popViewControllerAnimated(true)
            
        }else{
            print("error")
        }
    }
    
    @IBAction func tapScreen(sender: AnyObject) {
        self.view.endEditing(true)
    }
}