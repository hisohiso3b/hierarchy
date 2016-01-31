//
//  PathVC.swift
//  Hierarchy
//
//  Created by hiso on 2015/06/02.
//  Copyright (c) 2015年 祐輔 花田. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import iAd

class PathVC: UIViewController {
    
    @IBOutlet weak var pathTextField: UITextField!
    
    let ud = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        //self.canDisplayBannerAds = true
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.863, green:0.078, blue:0.235, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //入力された階層へ移動
    @IBAction func goPath(sender: AnyObject) {
        ud.setObject(pathTextField.text, forKey: "selected_path")
        let next: UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PathTVC") 
        //self.presentViewController(next, animated: true, completion: nil)
        self.navigationController!.pushViewController(next as UIViewController, animated: true)
    }
    
    //キーボードを下げる
    @IBAction func tapScreen(sender: AnyObject) {
        self.view.endEditing(true)

    }
}
