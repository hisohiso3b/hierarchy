//
//  UpdateProfileVC.swift
//  Hierarchy
//
//  Created by hiso on 2015/06/03.
//  Copyright (c) 2015年 祐輔 花田. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class UpdateProfileVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, NSURLSessionTaskDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var redBar: UISlider!
    @IBOutlet weak var greenBar: UISlider!
    @IBOutlet weak var blueBar: UISlider!
    
    let ud = NSUserDefaults.standardUserDefaults()
    let ipc:UIImagePickerController = UIImagePickerController();
    
    var rnum: Int = 1
    var image_reload_count = 0
    
    override func viewDidLoad() {
        nameTextField.delegate = self
        
        rnum = ud.integerForKey("image_num")
        
        redBar.value = ud.floatForKey("red")
        greenBar.value = ud.floatForKey("green")
        blueBar.value = ud.floatForKey("blue")
        
        ipc.delegate = self
        
        if ud.objectForKey("mybackimage") != nil {
            selectedImageView.image = UIImage(data: ud.objectForKey("mybackimage") as! NSData)
            selectedImageView.image = cropThumbnailImage(selectedImageView.image!, w: Int(selectedImageView.image!.size.width), h: Int(selectedImageView.image!.size.height) /*200*/)
            selectedImageView.bounds.size = CGSize(width:100, height:50)
        }
        nameTextField.text = ud.stringForKey("name")
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if ud.objectForKey("mybackimage") != nil {
            selectedImageView.image = UIImage(data: ud.objectForKey("mybackimage") as! NSData)
            selectedImageView.image = cropThumbnailImage(selectedImageView.image!, w: Int(selectedImageView.image!.size.width), h: Int(selectedImageView.image!.size.height) /*200*/)
            selectedImageView.bounds.size = CGSize(width:100, height:50)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveProfilePushed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
        if(nameTextField.text != "" && selectedImageView.image != nil){
            var imagedata: NSData = UIImagePNGRepresentation(selectedImageView.image!)!
            //let encodedImage = imagedata.base64EncodedDataWithOptions(.allZeros)
            //println(String(_cocoaString: encodedImage))
            
            let tempid = ud.stringForKey("id")!
            let params: [String: AnyObject] = [
                "userid": tempid,
                "name": nameTextField.text!,
                "image_num": Int(rnum),
                "red": redBar.value,
                "green": greenBar.value,
                "blue": blueBar.value
            ]
            print("setJSON")
            print(params)
            
            let jsonparams = JSON(params)
            print(jsonparams.dictionary!)
            
            
            
            net.POST("/user_update", params: params, successHandler: {
                responseData in
                //let result = responseData.json(error: nil)
                NSLog("Success")
                
                
                //IMAGE_UPLOAD
                /*
                let data:NSData = imagedata//NSData(data: UIImageJPEGRepresentation(image, 1))
                let tmpFilePath:String = NSTemporaryDirectory() + "icon_tmp.png"
                println(tmpFilePath)
                data.writeToFile(tmpFilePath, atomically: true)
                
                let myCofig:NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
                let myRequest:NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string:baseurl+"/image_upload")!)
                myRequest.HTTPMethod = "POST"
                let mySession:NSURLSession = NSURLSession(configuration: myCofig, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
                var myTask:NSURLSessionUploadTask = mySession.uploadTaskWithRequest(myRequest, fromData: data)
                myTask.resume()
                */
                
                /*
                net.upload(absoluteUrl: baseurl+"/image_upload", data: data, progressHandler: { progress in
                    NSLog("progress: \(progress)")
                    println("Uploaded")
                    }, completionHandler: { error in
                        NSLog("Upload completed")
                })
                */
                
                //self.ud.setObject("", forKey: "id")
                self.ud.setObject(self.nameTextField.text, forKey: "name")
                self.ud.setInteger(Int(self.rnum), forKey: "image_num")
                self.ud.setFloat(self.redBar.value, forKey: "red")
                self.ud.setFloat(self.greenBar.value, forKey: "green")
                self.ud.setFloat(self.blueBar.value, forKey: "blue")
                self.ud.setObject(UIImageJPEGRepresentation(self.selectedImageView.image!, 0.7), forKey: "mybackimage")
                
                
                }, failureHandler: { error in
                    NSLog("Error")
                    self.navigationController?.popViewControllerAnimated(true)
            })
            
            
            
            //IMAGE_UPLOAD
            //post_params("/user_update", params: params)
            /*
            Alamofire.request(.POST, baseurl + "/user_update",parameters: params, encoding: .JSON).response({ (_, _, result, err) -> Void in
                
                if err == nil {
                    //var res_json = JSON(result!)
                    //println(result)
                    
                    self.ud.setObject(self.nameTextField.text, forKey: "name")
                    self.navigationController?.popViewControllerAnimated(true)
                    
                    
                    let data:NSData = imagedata//NSData(data: UIImageJPEGRepresentation(image, 1))
                    let tmpFilePath:String = NSTemporaryDirectory() + "icon_tmp.png"
                    println(tmpFilePath)
                    data.writeToFile(tmpFilePath, atomically: true)
                    
                    //Alamofire.upload(.POST, baseurl+"/image_upload", tmpFilePath )
                    var fileurl: NSURL? = NSURL(fileURLWithPath: tmpFilePath)
                    
                    println(fileurl)
                    
                    Alamofire.upload(.POST, baseurl+"/image_upload", fileurl!)
                }
                
            })
            */
        
            
            /*
            .responseJSON { (_, _, result, _) in
            println(result)
            var res_json = JSON(result!)
            self.ud.setObject(res_json[0]["name"].string, forKey: "name")
            self.ud.setObject(res_json[0]["_id"].string, forKey: "id")
            
            println(self.ud.stringForKey("name")!)
            println(self.ud.stringForKey("id")!)
            
            let next: UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("TabController") as! UIViewController
            self.presentViewController(next, animated: true, completion: nil)
            }
            */
            
        }else{
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    //画像をランダムで1つ設定する
    @IBAction func selectImage(sender: AnyObject) {
        rnum = Int(arc4random() % 59 + 1)
        
        //20回以上連続で画像取得するとアプリを強制終了（サーバー保護）
        if image_reload_count < 20{
            let url = NSURL(string: baseurl+"/get_image/\(self.rnum)")
            var err: NSError?
            let imageData :NSData = NSData(contentsOfURL: url!)!
            let img = UIImage(data:imageData)
            //self.selectedImageView.image = cropThumbnailImage(img!, w: Int(img!.size.width)/5, h: Int(img!.size.height)/5 /*200*/)
            //self.selectedImageView.image = img
            self.selectedImageView.image = cropThumbnailImage(img!, w: Int(selectedImageView.image!.size.width), h: Int(selectedImageView.image!.size.height) /*200*/)
            image_reload_count++
            
        }else{
            exit(0)
        }
        
    }
    
    
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if info[UIImagePickerControllerOriginalImage] != nil {
            let image:UIImage = info[UIImagePickerControllerOriginalImage]  as! UIImage
            selectedImageView.image = cropThumbnailImage(image, w: Int(image.size.width)/5, h: Int(image.size.height)/5 /*200*/)
        }
        //allowsEditingがtrueの場合 UIImagePickerControllerEditedImage
        //閉じる処理
        picker.dismissViewControllerAnimated(true, completion: nil);
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
    
    
    //
    //POST req
    //
    func post_params(reqto: String, params: [String: AnyObject!]) -> Bool {
        let request = NSMutableURLRequest(URL: NSURL(string: baseurl+reqto)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        //var params = ["username":"jameson", "password":"password"] as Dictionary<String, String>
        
        var err: NSError?
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch let error as NSError {
            err = error
            request.HTTPBody = nil
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            print("Response: \(response)")
            let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("Body: \(strData)")
            do {
                var err: NSError?
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                
                if(err != nil) {
                    print(err!.localizedDescription)
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: '\(jsonStr)'")
                }
                else {
                    if let parseJSON = json {
                        let success = parseJSON["success"] as? Int
                        print("Succes: \(success)")
                    }
                    else {
                        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print("Error could not parse JSON: \(jsonStr)")
                    }
                }
            } catch {
                
            }
        })
        
        task.resume()
        return true
    }
    
    
    /*
    通信終了時に呼び出されるデリゲート.
    */
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        print("didCompleteWithError")
        
        // エラーが有る場合にはエラーのコードを取得.
        print(error?.code)
        print(error)
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest?) -> Void) {
        
        print("willPerformHTTPRedirection")
        
    }
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        print("didSendBodyData")
        
    }
    
    @IBAction func tapScreen(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        self.view.endEditing(true)
        //textField.resignFirstResponder()
        return true
    }
    
    @IBAction func tapColorButton(sender: AnyObject) {
        (sender as! UIButton).backgroundColor = UIColor(
            red: CGFloat(redBar.value),
            green: CGFloat(greenBar.value),
            blue: CGFloat(blueBar.value),
            alpha: 1
        );
    }
}

