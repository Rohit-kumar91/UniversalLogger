//
//  RevealSliderModel.swift
//  UniversalLogger
//
//  Created by cyno on 10/4/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import UIKit
import PromiseKit
import LocalAuthentication

class RevealSliderModel: NSObject {
    
    
    
    func updateThumbInfoToDB(dataDictionary:[String:Any], header:[String:String])->Promise<[String:Any]> {

        return Promise {seal in
            
            let apiURl =  "http://45.40.133.173:8097/api/User/UpdateThumbInfo"
            APIManager.apiManager.callPostService(urlString: apiURl, parameters: dataDictionary, header: header).done{ json in
                
                seal.fulfill(json)
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
    
    
    func checkingThumbExistingOrNot()  {
        
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(
            LAPolicy.deviceOwnerAuthenticationWithBiometrics,
            error: &error) {
            
            
            print("Existing.....")
            
        } else {
            // Device cannot use biometric authentication
            if let err = error {
                switch err.code{
                    
                case LAError.Code.biometryNotEnrolled.rawValue:
                    
                    AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle , message: err.localizedDescription, actionTitles: [globalConstants.alertController.kOK], actions: [
                        {()->() in
                            UIApplication.shared.open(URL(string:"App-Prefs:root=General")!, options: [:], completionHandler: nil)
                        }]
                    )
                    
                case LAError.Code.passcodeNotSet.rawValue:
                    
                    AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle , message: err.localizedDescription, actionTitles: [globalConstants.alertController.kOK], actions: [
                        {()->() in
                            UIApplication.shared.open(URL(string:"App-Prefs:root=General")!, options: [:], completionHandler: nil)
                        }]
                    )
                    
                case LAError.Code.biometryNotAvailable.rawValue:
                    
                    AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle , message: err.localizedDescription, actionTitles: [globalConstants.alertController.kOK], actions: [
                        {()->() in
                            UIApplication.shared.open(URL(string:"App-Prefs:root=General")!, options: [:], completionHandler: nil)
                        }]
                    )
                default:
                    
                    print("Unknown error", err.localizedDescription)
                    
                }
            }
        }
    }
}
