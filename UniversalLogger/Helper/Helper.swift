//
//  Helper.swift
//  UniversalLogger
//
//  Created by Cynoteck6 on 7/27/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import Foundation
import UIKit



class Helper {
    
    
    class func saveUserDefault(key: String, value: String ) {
        let def = UserDefaults.standard
        def.set(value, forKey: key)
        def.synchronize()
        restartApp()
    }
    
    class func restartApp() {
        guard  let window = UIApplication.shared.keyWindow else {
            return
        }
        
      //  let sb = UIStoryboard(name: "Main", bundle: nil)
     //   var vc: UIViewController
        
//        if getUserDefault(key: "abc") == nil {
//            vc = sb.instantiateInitialViewController()!
//        } else{
//            vc = sb.instantiateViewController(withIdentifier: "dashboardID")
//        }
        
//        window.rootViewController = vc
        UIView.transition(with: window, duration: 0.5, options: .curveEaseIn, animations: nil, completion: nil)
        
        //.transitionFlipFromTop
    }
    
    class func getUserDefault(key: String) -> String?{
        let def = UserDefaults.standard
        return def.object(forKey: key) as? String
    }
    
    
    class func removeUserDefault(key: String) {
        let def = UserDefaults.standard
        def.removeObject(forKey: key)
        def.synchronize()
        
        guard  let window = UIApplication.shared.keyWindow else {
            return
        }
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        var vc: UIViewController
        vc = sb.instantiateViewController(withIdentifier: "loginID")
        window.rootViewController = vc
        UIView.transition(with: window, duration: 0.5, options: .curveEaseIn, animations: nil, completion: nil)
        
    }

}



