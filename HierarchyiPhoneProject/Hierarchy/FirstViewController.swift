//
//  FirstViewController.swift
//  Hierarchy
//
//  Created by hiso on 2015/06/02.
//  Copyright (c) 2015年 祐輔 花田. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class FirstViewController: UIViewController {
    
    let ud = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        if ud.stringArrayForKey("block_users") != nil{
            block_users = ud.stringArrayForKey("block_users")! as [String]
        }
            
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //EULA既読確認
        if !ud.boolForKey("EULA") {
            //初回起動であればEULA表示
            let alertController = UIAlertController(title: "End-User Lisence Agreement", message: eula, preferredStyle: .Alert)
            let otherAction = UIAlertAction(title: "Agree", style: .Default) {
                action in print("pushed OK!")
                
                self.ud.setObject(true, forKey: "EULA")
                
                if self.ud.boolForKey("EULA") {
                    
                    self.createUser()
                    
                }
            }
            
            //EULAに承諾できない場合、アプリを終了
            let cancelAction = UIAlertAction(title: "DISAGREE", style: .Cancel) {
                action in
                print("Pushed CANCEL!")
                exit(0)
            }
            
            alertController.addAction(otherAction)
            alertController.addAction(cancelAction)
            presentViewController(alertController, animated: true, completion: nil)
        }
        
        //初回起動後、承諾後すぐに終了してしまった場合のバグ修正。
        if ud.boolForKey("EULA") {
            
            createUser()
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    * 新規ユーザー作成、初期値を設定
    */
    func createUser (){
        //ユーザー作成と初期値代入。
        if(ud.stringForKey("name") == nil || ud.stringForKey("id") == nil){
            Alamofire.request(.GET, baseurl + "/create_user")
                .responseJSON { (res) in
                    print(res.result.value)
                    var res_json = JSON(res.result.value!)
                    self.ud.setObject(res_json[0]["name"].string, forKey: "name")
                    self.ud.setObject(res_json[0]["_id"].string, forKey: "id")
                    
                    print(self.ud.stringForKey("name")!)
                    print(self.ud.stringForKey("id")!)
                    
                    //red:0.863, green:0.078, blue:0.235, alpha: 1.0
                    let params =
                    [
                        "userid": res_json[0]["_id"].string!,
                        "name": res_json[0]["name"].string!,
                        "image_num": 1,
                        "red": 0.137,
                        "green": 0.922,
                        "blue": 0.765
                    ]
                    print("setJSON")
                    print(params)
                    
                    let jsonparams = JSON(params)
                    print(jsonparams.dictionary!)
                    
                    
                    net.POST("/user_update", params: params, successHandler: {
                        responseData in
                        //let result = responseData.json(error: nil)
                        NSLog("Success")
                        
                        let url = NSURL(string: baseurl+"/get_image/\(1)")
                        let imageData :NSData = NSData(contentsOfURL: url!)!
                        let img = UIImage(data:imageData)
                        
                        self.ud.setObject(UIImageJPEGRepresentation(img!, 0.7), forKey: "mybackimage")
                        self.ud.setInteger(1, forKey: "image_num")
                        self.navigationController?.popViewControllerAnimated(true)
                        
                        let next: UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("TabController")
                        self.presentViewController(next, animated: true, completion: nil)
                        
                        }, failureHandler: { error in
                            NSLog("Error")
                            self.ud.setObject(nil, forKey: "id")
                            exit(0)
                    })
                    
            }
        }else{
            let next: UIViewController = storyboard!.instantiateViewControllerWithIdentifier("TabController")
            presentViewController(next, animated: true, completion: nil)
        }
    }


}
