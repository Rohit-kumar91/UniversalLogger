//
//  ResetPasswordVC.swift
//  UniversalLogger
//
//  Created by Cynoteck6 on 7/27/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import UIKit
import SwiftyJSON
import SSSpinnerButton



class ResetPasswordVC: UIViewController, UITextFieldDelegate {

    @IBOutlet var resetPasswordContainer: UIView!
    @IBOutlet var sendButtonOutlet: UIButton!
    @IBOutlet var currentPasswordTextfield: UITextField!
    @IBOutlet var newPasswordTextfield: UITextField!
    @IBOutlet var confirmPasswordTextfield: UITextField!
    @IBOutlet var blurView: UIView!
    @IBOutlet var spinner: SSSpinnerButton!
    
    var resetPasswordObj: ResetPasswordModel = ResetPasswordModel()
    var userEmailId: String = String()
    var forgotPassword = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // resetPasswordContainer View customization
        resetPasswordContainer.setBorder()

        // sendButtonOutlet View customization
        sendButtonOutlet.buttonWithShadow()
        
        currentPasswordTextfield.delegate = self
        newPasswordTextfield.delegate = self
        confirmPasswordTextfield.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        let currentPassword = currentPasswordTextfield.text
        let newPassword = newPasswordTextfield.text
        let confirmPassword = confirmPasswordTextfield.text
        
        print("new Password ", newPassword!)
        print("confirm Password ", confirmPassword!)
        
        resetPasswordObj.confirmPassword = confirmPassword
        resetPasswordObj.newPassword = newPassword
        resetPasswordObj.currentPassword = currentPassword
        resetPasswordObj.forgotpassword = forgotPassword
        
        print("reset password ", forgotPassword)
        
        if !resetPasswordObj.validatePassword()
        {
            
            AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: resetPasswordObj.alertMessage, actionTitles: [globalConstants.alertController.kOK], actions: nil)
            
        } else {
            
            var dataDictionary = [String:String]()
            dataDictionary["Password"] = currentPassword
            dataDictionary["ConfirmPassword"] = confirmPassword
            dataDictionary["EmaiIId"] = userEmailId
            dataDictionary[globalConstants.apiUrl.kDevice_ID] = appDelegate.deviceID
            
            var dict = [String:Any]()
            dict[globalConstants.apiUrl.kData] = dataDictionary
            print("data dict", dict)
            
            resetPasswordServiceCall(dataDictionary: dict)
            // handle spinner
            blurView.isHidden = false
            spinner.isHidden = false
            spinner.startAnimate(spinnerType: SpinnerType.ballClipRotate, spinnercolor: UIColor.white, complete: nil)
        }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(textField == currentPasswordTextfield)
        {
            newPasswordTextfield.becomeFirstResponder()
            
        }
        else if(textField == newPasswordTextfield)
        {
            
            confirmPasswordTextfield.becomeFirstResponder()
        }
        else if (textField == confirmPasswordTextfield)
        {
            confirmPasswordTextfield.resignFirstResponder()

        }
        return true
    }
    
    func resetPasswordServiceCall(dataDictionary: [String: Any])  {
        
        let headers = [ "Content-Type": "application/json" ]

        resetPasswordObj.resetPasswordService(dataDictionary: dataDictionary, header: headers).done { json-> Void in
            
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
                
                self.performSegue(withIdentifier: "backToSignIn", sender: self)
                
                
            } else {
                
                let responseMessage = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseMessage].stringValue
                
                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: responseMessage, actionTitles: [globalConstants.alertController.kOK], actions: nil)            }
            
            }.catch { error in
                
                self.spinner.stopAnimate(complete: {
                    
                    self.blurView.isHidden = true
                    self.spinner.isHidden = true
                    
                })
                
                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: error.localizedDescription, actionTitles: [globalConstants.alertController.kOK], actions: nil)
                
                print("error is ", error.localizedDescription)
        }
    }
    
    
    /*!
     **********************************************
     * @Author name Pushpank Kumar
     * @Date 24 July 2018
     * @Input Parameter Alert Message
     **********************************************
     */
    
//    private func showAlertWithMessage(alertMessage:String) {
//        
//        let alertController = UIAlertController(title:globalConstants.alertController.kAlertTitle, message:alertMessage, preferredStyle: UIAlertControllerStyle.alert)
//        alertController.addAction(UIAlertAction(title: globalConstants.alertController.kOK, style: UIAlertActionStyle.default, handler: nil))
//        self.present(alertController, animated: true, completion: nil)
//    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
