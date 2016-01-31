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
import TTTAttributedLabel
import DZNEmptyDataSet

class PathTVC: UITableViewController, UIGestureRecognizerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, TTTAttributedLabelDelegate {
    
    let ud = NSUserDefaults.standardUserDefaults()
    var connectcount = 0
    var here: String = "/"
    
    //array of entries
    var entries = JSON("")
    
    override func viewDidLoad() {
        //self.canDisplayBannerAds = true
        
        // UILongPressGestureRecognizer宣言
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: "cellLongPressed:")
        longPressRecognizer.delegate = self
        // tableViewにrecognizerを設定
        tableView.addGestureRecognizer(longPressRecognizer)
        
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.863, green:0.078, blue:0.235, alpha: 0.7)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        //removeAllSubviews(tableView!)
        self.tableView.estimatedRowHeight = 10
        self.tableView.rowHeight = UITableViewAutomaticDimension
        here = ud.stringForKey("selected_path")!
        
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        
        reload(self)
        
        //after reload set table size and position
        self.tableView.bounds.size = CGSize(width:self.view.bounds.width,height:self.view.bounds.height)
        self.tableView.layer.position = CGPoint(x:self.view.bounds.width/2,y:self.view.bounds.height/2 - 80)
        //self.tableView.backgroundColor = UIColor(red:0.963, green:0.380, blue:0.540, alpha: 0.5)
        //self.view.backgroundColor = UIColor(red:0.963, green:0.480, blue:0.640, alpha: 1.0)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.tableView.bounds.size = CGSize(width:self.view.bounds.width,height:self.view.bounds.height + 50)
        self.tableView.layer.position = CGPoint(x:self.view.bounds.width/2,y:self.view.bounds.height/2 - 80)
        //ud.setObject(self.title, forKey: "selected_path")
        
        print("selected_path")
        self.title = here//ud.stringForKey("selected_path")
        ud.setObject(here, forKey: "selected_path")
        
        if here.characters.count > 12 {
            let myString = here
            let length = myString.characters.count
            
            var startIndex:String.Index
            var endIndex:String.Index
            
            startIndex = myString.startIndex.advancedBy(length - 10) //末尾から〜文字目
            endIndex = myString.startIndex.advancedBy(length) //最後の文字
            let newString = myString.substringWithRange(Range(start:startIndex ,end:endIndex))
            
            self.title = ".."+newString
        }
        
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
        var cell = tableView.dequeueReusableCellWithIdentifier("HierarchyCell", forIndexPath: indexPath) as! CustomCell//UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: "user")
        
        //cell.imageView?.image = cropThumbnailImage(UIImage(named: "blog_import_54af2856f3a44.png")!, w: 50, h: 50)
            
        //get entry
        var entry = entries[entries.count-indexPath.row-1]// as! NSDictionary
        
        //set title
        //cell.textLabel!.text = entry["name"].string// as? String!
        //cell.detailTextLabel?.text = "" + entry["contents"].string!
        
        var backimage = UIImage(named: "back2.gif")!
        //cell.backgroundImageView.image = cropThumbnailImage(UIImage(named: "l_03.gif")!, w: 200, h: 50)
        cell.backgroundImageView.image = cropThumbnailImage(backimage, w: Int(backimage.size.width), h: 200)
        cell.backgroundImageView.alpha = 0.5
        //cell.nameLabel.text = String(entries.count-indexPath.row) + " : " + entry["name"].string!// as? String!
        //TTTAttributedlabel
        cell.titleLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
        cell.titleLabel.delegate = self
        ////
        cell.titleLabel.text = String(entries.count-indexPath.row) + " : " + entry["name"].string! + "\n" + entry["contents"].string!
        cell.path = entry["my_hierarchy"].string!
        cell.id = entry["_id"].string!
        
        var tempIMGnum = entry["image_num"].int!
        if ud.objectForKey("\(tempIMGnum)") != nil {
            cell.backgroundImageView.image = UIImage(data: ud.objectForKey("\(tempIMGnum)") as! NSData)
            cell.backgroundImageView.image = cropThumbnailImage(cell.backgroundImageView.image!, w: Int(cell.backgroundImageView.image!.size.width), h: 200)
        }else{
            var imgnum = NSString(string: "\(tempIMGnum)").intValue
            let url = NSURL(string: baseurl+"/get_image/\(imgnum)")
            var err: NSError?
            var imageData :NSData = NSData(contentsOfURL: url!)!
            var img = UIImage(data:imageData)
            cell.backgroundImageView.image = img
            
            ud.setObject(imageData, forKey: "\(tempIMGnum)")
        }
        
        print(entry)
        var red = CGFloat( entry["red"].float! )
        var green = CGFloat( entry["green"].float! )
        var blue = CGFloat( entry["blue"].float! )
        cell.titleLabel.textColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        
        cell.titleLabel.text = cell.titleLabel.text! + "\n\n" + entry["create_date"].string!
        for item in block_users {
            print(entry["id"].string!)
            if entry["id"].string! == item {
                cell.titleLabel.text = "blocked"
                print("match block")
            }
        }
        
        //cell.detailTextLabel?.text = cell.detailTextLabel!.text! + "Phone:" + entry["phone"].string!
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func refresh(sender: AnyObject){
        reload(self)
        self.refreshControl!.endRefreshing()
        
        //self.tableView.emptyDataSetSource = self;
        //self.tableView.emptyDataSetDelegate = self;
    }
    
    //reload
    @IBAction func reload(sender: AnyObject) {
        
        let url = baseurl + "/path_get"
        
        let params : [String:AnyObject!] =
        [
            "parents_hierarchy" : here
        ]
        
        Alamofire.request(.GET, url, parameters: params)
            .responseJSON { res in
                if(res.result.error != nil) {
                    NSLog("Error: \(res.result.error)")
                    print(res.result)
                    print(res.result.value)
                    
                    let alert = UIAlertView()
                    alert.title = "Connection Error"
                    alert.message = ""
                    alert.addButtonWithTitle("OK")
                    alert.show()
                    
                } else {
                    NSLog("Success: \(url)\n")
                    self.entries = (JSON(res.result.value!))
                    print(self.entries)
                    print(self.entries[0]["contents"])
                    self.tableView.reloadData()
                    
                    if self.entries == [] {
                        self.makeEmptyLabel("コンテンツは0件です\n\nあなたが最初の投稿者に\nなってみましょう！\n\n右上の\"Post here\"からこの階層へ書込みできます")
                    }else{
                        for view in self.view.subviews {
                            if view is UILabel {
                                view.removeFromSuperview()
                            }
                        }
                    }
                }
                
                self.connectcount++
                if(self.connectcount>end_num){
                    exit(0)
                }
        }
        
        self.tableView.layer.position = CGPoint(x:self.view.bounds.width/2,y:self.view.bounds.height/2 - 80)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Num: \(indexPath.row)")
        //println("Value: \(entries[indexPath.row])")
        
        ud.setObject(entries[entries.count-indexPath.row-1]["my_hierarchy"].string!, forKey: "selected_path")
        
        let next: UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("PathTVC") 
        //self.presentViewController(next, animated: true, completion: nil)
        self.navigationController!.pushViewController(next as UIViewController, animated: true)
        
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
    
    @IBAction func postPushed(sender: AnyObject) {
        ud.setObject(here, forKey: "selected_path")

    }
    
    func cropThumbnailImage(image :UIImage, w:Int, h:Int) ->UIImage
    {
        // リサイズ処理
        
        let origRef    = image.CGImage;
        let origWidth  = Int(CGImageGetWidth(origRef))
        let origHeight = Int(CGImageGetHeight(origRef))
        var resizeWidth:Int = 0, resizeHeight:Int = 0
        
        if (origWidth < origHeight) {
            resizeWidth = w
            resizeHeight = origHeight * resizeWidth / origWidth
        } else {
            resizeHeight = h
            resizeWidth = origWidth * resizeHeight / origHeight
        }
        
        let resizeSize = CGSizeMake(CGFloat(resizeWidth), CGFloat(resizeHeight))
        UIGraphicsBeginImageContext(resizeSize)
        
        image.drawInRect(CGRectMake(0, 0, CGFloat(resizeWidth), CGFloat(resizeHeight)))
        
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // 切り抜き処理
        
        let cropRect  = CGRectMake(
            CGFloat((resizeWidth - w) / 2),
            CGFloat((resizeHeight - h) / 2),
            CGFloat(w), CGFloat(h))
        let cropRef   = CGImageCreateWithImageInRect(resizeImage.CGImage, cropRect)
        let cropImage = UIImage(CGImage: cropRef!)
        
        return cropImage
    }
    
    @IBAction func goProfile(sender: AnyObject) {
        
    }
    
    func removeAllSubviews(parentView: UITableView){
        let subviews = parentView.subviews
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    
    
    
    
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
    
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?  {
        // 1
        let shareAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Profile" , handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
            // 2
            /*
            let shareMenu = UIAlertController(title: nil, message: "Share using", preferredStyle: .ActionSheet)
            
            let twitterAction = UIAlertAction(title: "Twitter", style: UIAlertActionStyle.Default, handler: nil)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            shareMenu.addAction(twitterAction)
            shareMenu.addAction(cancelAction)
            
            
            self.presentViewController(shareMenu, animated: true, completion: nil)
            */
            
            self.ud.setObject(self.entries[self.entries.count-indexPath.row-1]["id"].string!, forKey: "selected_id")
            
            let next: UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("ProfileVC") 
            //self.presentViewController(next, animated: true, completion: nil)
            self.navigationController!.pushViewController(next as UIViewController, animated: true)
            
            print("GoProfile")
        })
        // 3
        let rateAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "☆" , handler: { (action:UITableViewRowAction, indexPath:NSIndexPath) -> Void in
            /*
            // 4
            let rateMenu = UIAlertController(title: nil, message: "Rate this App", preferredStyle: .ActionSheet)
            
            let appRateAction = UIAlertAction(title: "Rate", style: UIAlertActionStyle.Default, handler: nil)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            rateMenu.addAction(appRateAction)
            rateMenu.addAction(cancelAction)
            
            
            self.presentViewController(rateMenu, animated: true, completion: nil)
            */
            
            if self.ud.objectForKey("favs") != nil {
                var temp:[String] = (self.ud.objectForKey("favs") as! [String])
                temp.append(self.entries[self.entries.count-indexPath.row-1]["my_hierarchy"].string!)
                self.ud.setObject(temp, forKey: "favs")
                print("fav inserted")
            }else{
                let temp:[String] = [
                    self.entries[self.entries.count-indexPath.row-1]["my_hierarchy"].string!
                ]
                self.ud.setObject(temp, forKey: "favs")
                print("fav created")
                
            }
            
            let favMenu = UIAlertController(title: nil, message: "Favorited", preferredStyle: .ActionSheet)
            let favAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            favMenu.addAction(favAction)
            print("faved")
            self.presentViewController(favMenu, animated: true, completion: nil)
            
        })
        // 5
        return [shareAction,rateAction]
    }
    
    
    func cellLongPressed(recognizer: UILongPressGestureRecognizer) {
        
        // 押された位置でcellのPathを取得
        let point = recognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        if indexPath == nil {
            
        } else if recognizer.state == UIGestureRecognizerState.Began  {
            // 長押しされた場合の処理
            print("長押しされたcellのindexPath:\(indexPath?.row)")
            //copy and paste
            UIPasteboard.generalPasteboard().string = self.entries[self.entries.count-indexPath!.row-1]["my_hierarchy"].string!
            let alertController = UIAlertController(
                title: "hierarchy cliped",
                message: self.entries[self.entries.count-indexPath!.row-1]["my_hierarchy"].string!,
                preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)

        }
    }
    
    //empty data set
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "コンテンツは0件です\n\nあなたが最初の投稿者に\nなってみましょう！\n\n右上の\"Post here\"からこの階層へ書込みできます"
        let font = UIFont(name: "ヒラギノ角ゴ ProN", size: 20)!
        return NSAttributedString(string: text, attributes: [NSFontAttributeName: font])
    }
    
    //TTTAttributedlabel
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        print("onclick!" + String(url))
        let app:UIApplication = UIApplication.sharedApplication()
        app.openURL(url)
    }
    
    //Make Label
    func makeEmptyLabel(text:String) -> UILabel{
        // ラベル作成
        let myLabel: UILabel = UILabel()
        // またはサイズを指定して初期化
        // let myLabel: UILabel = UILabel(frame: CGRectMake(0,0,300,100))
        
        // サイズ
        myLabel.frame = CGRectMake(0,0, UIScreen.mainScreen().bounds.width-50, UIScreen.mainScreen().bounds.height/2)
        
        // 位置
        myLabel.layer.position = CGPoint(x: self.view.bounds.width/2,y: 200)
        
        // 背景色
        myLabel.backgroundColor = UIColor.redColor()
        myLabel.alpha = 0.5
        
        // 文字
        myLabel.text = text
        
        // フォントサイズ
        myLabel.font = UIFont.systemFontOfSize(40)
        
        // 文字色
        myLabel.textColor = UIColor.whiteColor()
        
        // 文字の影の色
        myLabel.shadowColor = UIColor.blueColor()
        
        // 文字を中央寄せ
        myLabel.textAlignment = NSTextAlignment.Center
        
        // 角丸
        myLabel.layer.masksToBounds = true
        
        // コーナーの半径
        myLabel.layer.cornerRadius = 20.0
        
        
        myLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        myLabel.numberOfLines = 0
        
        myLabel.font = UIFont(name: "ヒラギノ角ゴ ProN", size: 20)!
        
        // Viewにラベルを追加
        self.view.addSubview(myLabel)
        
        return myLabel
    }

}