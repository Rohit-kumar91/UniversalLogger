
//
//  LinkSupervisorVC.swift
//  UniversalLogger
//
//  Created by Cynoteck6 on 8/10/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import UIKit
import SwiftyJSON


class LinkSupervisorVC: UIViewController {
    
    
    @IBOutlet var emailAddressTextfield: UITextField!
    
    
    @IBOutlet weak var buttonSend: UIButton!
    lazy var databaseID = Int()
    lazy var userID = Int()
    lazy var sp_emailId:String = String()
    
    let linkSupervisorModel = LinkSupervisorModel()


    override func viewDidLoad() {
        super.viewDidLoad()
        if sp_emailId == "0"{
            
            // no user supervisor...
        }else{
            
            buttonSend.setTitle("EDIT SUPERVISOR", for: .normal)
            emailAddressTextfield.text = sp_emailId
            emailAddressTextfield.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        
        let emailAddress = emailAddressTextfield.text!
        
        if emailAddress == sp_emailId {
            
            let alertController = UIAlertController(title:globalConstants.alertController.kAlertTitle, message: "Already Linked email id.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: globalConstants.alertController.kOK, style: .default, handler: { _ in
            }))
            
            self.present(alertController, animated: true, completion: nil)

        }else {
            
            var universalLoggerDB = [String:Any]()
            universalLoggerDB["DatabaseID"] = databaseID
            universalLoggerDB["User_ID"] = userID
            
            var supervisorDictionary = [String: String]()
            supervisorDictionary["EmaiIId"] = emailAddress
            
            var dataDictionary = [String: Any]()
            dataDictionary["ULRDB"] = universalLoggerDB
            dataDictionary["ULUsers"] = supervisorDictionary
            
            var linkSupervisorDictionary = [String :Any]()
            linkSupervisorDictionary["data"] = dataDictionary
            
            self.linkSupervisor(dataDictionary: linkSupervisorDictionary)

        }
   
    }
    
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func linkSupervisor(dataDictionary:[String:Any]) {
        
        
        let token = UserDefaults.standard.string(forKey: "token") as! String
        let bearerToken = "Bearer \(token)"
        print("token ", bearerToken)
        
        let header =  [ "Content-Type": "application/json", "Authorization" : bearerToken ]
        
        
        linkSupervisorModel.linkDatabasetoSupervisor(dataDictionary: dataDictionary, header: header).done { json-> Void in
            
            // stop spinner
            //            self.spinner.stopAnimate(complete: {
            //                self.blurView.isHidden = true
            //                self.spinner.isHidden = true
            //            })
            
            let jsonDictionary = JSON(json)
            
            print("json is ", jsonDictionary)
            
            let responseStatus = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseStatus].boolValue
            
            if responseStatus {
                
                let responseCode = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseCode].intValue
                
                let message = jsonDictionary[globalConstants.apiUrl.kResponse]["ResponseMessage"].stringValue
                
                if responseCode == 200 {
                    
                    self.view.endEditing(true)
                    
                    let alertController = UIAlertController(title:globalConstants.alertController.kAlertTitle, message: message, preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: globalConstants.alertController.kOK, style: .default, handler: { _ in
                        self.navigationController?.popViewController(animated: true)
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
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
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
