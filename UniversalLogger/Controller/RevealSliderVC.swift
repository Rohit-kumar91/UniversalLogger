//  RevealSliderVC.swift
//  UniversalLogger
//  Created by Cynoteck on 04/09/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.

import UIKit
import SwiftyJSON
import LocalAuthentication

class RevelSliderCell: UITableViewCell {
    
    let revealSliderModelObject:RevealSliderModel = RevealSliderModel()
    @IBOutlet weak var switchButtonOutlet: UISwitch!
    @IBOutlet weak var cellLabelOutlet: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    
    @IBAction func SwitchButton(_ sender: Any) {
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(
            LAPolicy.deviceOwnerAuthenticationWithBiometrics,
            error: &error) {
            
            self.upDateThumbInfo(dataDictionary: [:])
            print("tapped")
            
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
    

    
    func upDateThumbInfo(dataDictionary:[String:Any]) {
        
        let token = UserDefaults.standard.string(forKey: "token")!
        let bearerToken = "Bearer \(token)"
        print("token ", bearerToken)
        
        let header =  [ "Content-Type": "application/json", "Authorization" : bearerToken ]
        revealSliderModelObject.updateThumbInfoToDB(dataDictionary:[:], header: header).done { json-> Void in
            
            let jsonDictionary = JSON(json)
            print("json is ", jsonDictionary)
            
            let responseStatus = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseStatus].boolValue
            
            if responseStatus {
                
                let responseCode = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseCode].intValue
                
                if responseCode == 200 {
                    
                    AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: "Changed Successfully", actionTitles: [globalConstants.alertController.kOK], actions: nil)
                    
                    let thumbInfoIs:Bool = jsonDictionary[globalConstants.apiUrl.kData]["Status"].boolValue
                        self.switchButtonOutlet.isOn = thumbInfoIs
                    
                    // Setting bool value for next time....
                    UserDefaults.standard.set(thumbInfoIs, forKey: globalConstants.touchSensor.kTouchSensor)

                    
                } else {
                    
                    // error
                }
                
            } else {
                
                let responseMessage = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseMessage].stringValue
                
                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: responseMessage, actionTitles: [globalConstants.alertController.kOK], actions: nil)
                
            }
            
            }.catch { error in
                print("error is ",error.localizedDescription)
                print("error is ", error)
        }
    }

}

class RevealSliderVC: UIViewController {
    
    
    @IBOutlet weak var emailLabelOutlet: UILabel!
    @IBOutlet weak var menuTableViewOutlet: UITableView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        emailLabelOutlet.text = appDelegate.currentUserEmail

    }
}

extension RevealSliderVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return globalConstants.sliderArray.kSliderArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RevelSliderCell
        cell.cellLabelOutlet.text = globalConstants.sliderArray.kSliderArray[indexPath.row]
        cell.imageView?.image = UIImage(named:globalConstants.sliderImageArray.kSliderImageArray[indexPath.row])
        
        if indexPath.row == globalConstants.sliderArray.kSliderArray.count - 1 {
            cell.switchButtonOutlet.isHidden = false
        }else{
            cell.switchButtonOutlet.isHidden = true
        }
        cell.switchButtonOutlet.isOn = appDelegate.currentThumbInfoBool
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            // terms and condition
        }else if indexPath.row == 1 {
            // privacy and policy
        }else if indexPath.row == 2 {
            // help
        }else if indexPath.row == 3 {
            // Logout
            
            let alert = UIAlertController(title: "Alert", message: "Are you sure you want to logut?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in switch action.style {
            case .default:
                UserDefaults.standard.removeObject(forKey: globalConstants.touchSensor.kTouchSensor)
                Helper.removeUserDefault(key: "token")
            case .cancel:
                print("cancellllll")
            case .destructive:
                print("destructive")
                }
            }))
            self.present(alert, animated: true, completion: nil)

        }else{
            // Touch id....
        }
    }
}
