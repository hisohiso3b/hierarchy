//
//  HierarchyCell.swift
//  Hierarchy
//
//  Created by hiso on 2015/06/02.
//  Copyright (c) 2015年 祐輔 花田. All rights reserved.
//

import UIKit
import Foundation
import TTTAttributedLabel

class CustomCell: UITableViewCell, TTTAttributedLabelDelegate {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: TTTAttributedLabel!
    
    var id: String = ""
    var path: String = ""
    var ud = NSUserDefaults.standardUserDefaults()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //titleLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
        //titleLabel.delegate = self
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func favPushed(sender: AnyObject) {
        
        print(path + id)
        if ud.objectForKey("favs") != nil {
            var temp:[String] = (ud.objectForKey("favs") as! [String])
            temp.append(path)
            ud.setObject(temp, forKey: "favs")
            print("fav inserted")
        }else{
            let temp:[String] = [
                path
            ]
            ud.setObject(temp, forKey: "favs")
            print("fav created")

        }
    }
    
    @IBAction func goProfile(sender: AnyObject) {
        ud.setObject(id, forKey: "selected_id")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let next: UIViewController = storyboard.instantiateViewControllerWithIdentifier("ProfileVC") 
    }
    
}