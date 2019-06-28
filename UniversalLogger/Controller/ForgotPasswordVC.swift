//
//  ForgotPasswordVC.swift
//  UniversalLogger
//
//  Created by Cynoteck6 on 7/26/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import UIKit
import SwiftyJSON
import SSSpinnerButton


class ForgotPasswordVC: UIViewController, UITextFieldDelegate {

    // MARK: Outlets
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var sendButtonOutlet: UIButton!
    @IBOutlet var spinner: SSSpinnerButton!
    @IBOutlet var blurView: UIView!
    
    // local Declarations
    var forgotPasswordObj: ForgotPasswordModel = ForgotPasswordModel()
    var userEmailId: String = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var forgotPassword = String()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        spinner.isHidden = true
        
        // sendButtonOutlet View customization
        sendButtonOutlet.buttonWithShadow()
        emailTextfield.becomeFirstResponder()
        emailTextfield.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(textField == emailTextfield) {
            
            emailTextfield.resignFirstResponder()
        }
    
        return true
    }
    
    
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        
        
        self.view.endEditing(true)

        var email = emailTextfield.text
        email = email?.trimmingCharacters(in: .whitespaces)

        forgotPasswordObj.email = email

        if !forgotPasswordObj.validateEmail() {
            
            AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: forgotPasswordObj.alertMessage, actionTitles: [globalConstants.alertController.kOK], actions: nil)
        }
         else {

            var dataDictionary = [String:String]()
            dataDictionary[globalConstants.apiUrl.kEmaiIId] = email
            dataDictionary[globalConstants.apiUrl.kDevice_ID] = appDelegate.deviceID

            var dict = [String:Any]()
            dict[globalConstants.apiUrl.kData] = dataDictionary
            print("data dict", dict)

            forgotPasswordServiceCall(dataDictionary: dict)

            // handle spinner
            blurView.isHidden = false
            spinner.isHidden = false
            spinner.startAnimate(spinnerType: SpinnerType.ballClipRotate, spinnercolor: UIColor.white, complete: nil)


        }
    }
    
    
    func forgotPasswordServiceCall(dataDictionary:[String:Any]) {
        
        let headers = [ "Content-Type": "application/json" ]

        forgotPasswordObj.forgotPasswordService(dataDictionary: dataDictionary, header: headers).done { json-> Void in
            
            // stop spinner
            self.spinner.stopAnimate(complete: {
                
                self.blurView.isHidden = true
                self.spinner.isHidden = true
                
            })
            
            let jsonDictionary = JSON(json)
            
            print("json is ", jsonDictionary)
            
            let responseStatus = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseStatus].boolValue
            
            if responseStatus {
                
                print("response ", jsonDictionary)
                
                self.forgotPassword = jsonDictionary[globalConstants.apiUrl.kData]["Password"].stringValue
                self.userEmailId = jsonDictionary[globalConstants.apiUrl.kData]["EmaiIId"].stringValue
                
                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle , message: "Please check your email to update a new password.", actionTitles: [globalConstants.alertController.kOK], actions: [
                    {()->() in
                        
                        self.performSegue(withIdentifier: "changePasswordID", sender: nil)
                        
                    }]
                )
                
            } else {
                
                let responseMessage = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseMessage].stringValue
                
                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: responseMessage, actionTitles: [globalConstants.alertController.kOK], actions: nil)
            }
            
            }.catch { error in
                
                self.spinner.stopAnimate(complete: {
                    
                    self.blurView.isHidden = true
                    self.spinner.isHidden = true
                    
                })
                
                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: error.localizedDescription, actionTitles: [globalConstants.alertController.kOK], actions: nil)
                
        }

    }
    
    
    @IBAction func unwindToResetPassword(segue:UIStoryboardSegue) {
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changePasswordID" {
            
            let resetPasswordVC = segue.destination as! ResetPasswordVC
            resetPasswordVC.userEmailId = userEmailId
            resetPasswordVC.forgotPassword = forgotPassword
 
        }
    }

}
