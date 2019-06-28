//
//  Extensions.swift
//  UniversalLogger
//
//  Created by Cynoteck6 on 8/10/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON


extension UIView {
    
    func setBorder()  {
        
        self.layer.borderColor = UIColor.init(red: 221/255, green: 221/255, blue: 221/255, alpha: 1).cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 8.0
    }
    
    func shadowUnderView()  {
        
        self.layer.shadowColor = UIColor(red: 226/255, green: 226/255, blue: 226/255, alpha: 1).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 1.0
        self.layer.masksToBounds = false
    }
 
}


extension JSON{
    
    mutating func appendIfArray(json:JSON){
        if var arr = self.array{
            arr.append(json)
            self = JSON(arr)
        }
    }
    
    mutating func appendIfDictionary(key:String,json:JSON){
        if var dict = self.dictionary{
            dict[key] = json;
            self = JSON(dict)
        }
    }
}


extension UIButton {
    
    func buttonWithShadow() {
        
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        self.layer.shadowOpacity = 6.7
        self.layer.shadowRadius = 3.0
        self.layer.masksToBounds = false
        self.titleLabel?.textColor = UIColor.init(red: 45/255, green: 57/255, blue: 73/255, alpha: 1.0)
    }
    
    func selectedButton(title:String, iconName: String){
        self.setTitle(title, for: .normal)
        self.setTitleColor(UIColor.init(red: 106/255, green: 212/255, blue: 141/255, alpha: 1), for: .normal)
        self.setImage(UIImage(named: iconName), for: .normal)
        self.setImage(UIImage(named: iconName), for: .highlighted)
        
    }
    
}




