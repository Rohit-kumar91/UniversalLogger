//
//  SignUpVC.swift
//  UniversalLogger
//
//  Created by Cynoteck6 on 7/24/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftyJSON
import SSSpinnerButton
import SwiftKeychainWrapper
import LocalAuthentication



class SignUpVC: UIViewController, UITextFieldDelegate {

    // MARK: Outlets
    @IBOutlet var signUpContainer: UIView!
    @IBOutlet var signUpButtonOutlet: UIButton!
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    @IBOutlet var signUpView: UIView!
    @IBOutlet var spinner: SSSpinnerButton!
    @IBOutlet var blurView: UIView!
    @IBOutlet var confirmPasswordTextfield: UITextField!
    
    // local Declarations
    var signUpObj: SignUpModel = SignUpModel()
    var customAlert : UIView = UIView()
    var email = String()
    var password = String()
    var confirmPassword = String()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var token  = String()
    lazy var coverView = UIView()
    lazy var dict = [String:Any]()
    lazy var dataDictionary = [String:Any]()




    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // signUpContainer View customization
        signUpContainer.setBorder()
        
        // signUpButtonOutlet View customization
        signUpButtonOutlet.buttonWithShadow()
        
        spinner.isHidden = true
        
        
    
        self.showCustomAlert()
        customAlert.isHidden = true
        coverView.isHidden = true


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)

        email = emailTextfield.text!
        password = passwordTextfield.text!
        confirmPassword = confirmPasswordTextfield.text!
        email = email.trimmingCharacters(in: .whitespaces)
        signUpObj.email = email
        signUpObj.password = password
        signUpObj.confirmPassword = confirmPassword
        
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        confirmPasswordTextfield.delegate = self
        


        if !signUpObj.validateEmail()
        {
            
            AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: signUpObj.alertMessage, actionTitles: [globalConstants.alertController.kOK], actions: nil)
        }
        else if !signUpObj.validatePassword()
        {
            
            AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: signUpObj.alertMessage, actionTitles: [globalConstants.alertController.kOK], actions: nil)
            
        } else {
            
            
            coverView.isHidden = false
            customAlert.isHidden = false
           


            
            var userDictionary = [String:Any]()
            userDictionary[globalConstants.apiUrl.kEmaiIId] = email
            userDictionary[globalConstants.apiUrl.kPassword] = password
            userDictionary[globalConstants.apiUrl.kDevice_ID] = appDelegate.deviceID
            dataDictionary["UL_Users"] = userDictionary
            print("data dict", dict)
            
        }
    }
    
    
    func signUpService(dataDictionary:[String:Any], touch:Bool)  {
        
        let headers = [ "Content-Type": "application/json" ]
        
        signUpObj.userSignUp(dataDictionary: dataDictionary, header: headers).done { json-> Void in
            
            self.spinner.stopAnimate(complete: {
                
                self.blurView.isHidden = true
                self.spinner.isHidden = true
                
            })
            
            let jsonDictionary = JSON(json)
            
            print("json is ", jsonDictionary)
            
            let responseStatus = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseStatus].boolValue
            
            print("response status ", responseStatus)
            
            if responseStatus {
                
                self.token = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kToken].stringValue
                
                if self.token != "" {
                    
                    UserDefaults.standard.set(touch, forKey: globalConstants.touchSensor.kTouchSensor)
                    
                    if !touch {
                        
                        Helper.saveUserDefault(key: "token", value:self.token)

                    }
                    
                    UserDefaults.standard.set(self.token, forKey: "token")
                    self.performSegue(withIdentifier: globalConstants.stroryboard.stroryboardSegueId.kDashboard, sender: nil)
                }
                
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
    
    
    /*!
     **********************************************
     * @Author name Pushpank Kumar
     * @Date 27 July 2018
     * Textfield delegates to handle the keyboard
     **********************************************
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if(textField == emailTextfield)
        {
            passwordTextfield.becomeFirstResponder()
            
        }
        else if(textField == passwordTextfield)
        {
            confirmPasswordTextfield.becomeFirstResponder()
        }
        else if(textField == confirmPasswordTextfield)
        {
            confirmPasswordTextfield.resignFirstResponder()

        }
        
        return true
    }
    
    
    
    
    
    func showCustomAlert() {
        
        let screenRect = UIScreen.main.bounds
        coverView = UIView(frame: screenRect)
        coverView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        self.view.addSubview(coverView)
        
        self.blurView.isHidden = true
        
        view.addSubview(customAlert)
        
        
        customAlert.backgroundColor = UIColor.white
        customAlert.alpha = 1.0
        customAlert.layer.cornerRadius = 8.0
        customAlert.translatesAutoresizingMaskIntoConstraints = false

        let sensorImageView = UIImageView()
        customAlert.addSubview(sensorImageView)
        var sensorIcon = UIImage()
        sensorIcon = #imageLiteral(resourceName: "touch-sensor-icon")
        sensorImageView.image = sensorIcon
        sensorImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let sensorMessageLabel = UILabel()
        customAlert.addSubview(sensorMessageLabel)
        sensorMessageLabel.text = "Would you like to use a touch ID to login in next time ? "
        sensorMessageLabel.numberOfLines = 0
        sensorMessageLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        sensorMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let noButton:UIButton = UIButton()
        noButton.backgroundColor = UIColor.init(red: 105/255, green: 144/255, blue: 221/255, alpha: 1)
        noButton.setTitle("NO", for: .normal)
        noButton.addTarget(self, action:#selector(self.noButtonTapped), for: .touchUpInside)
        customAlert.addSubview(noButton)
        noButton.titleLabel?.font =  UIFont(name: "helvetica-bold", size: 15)
        noButton.clipsToBounds = true
        noButton.layer.cornerRadius = 8.0
        noButton.layer.maskedCorners = [.layerMinXMaxYCorner]
        noButton.translatesAutoresizingMaskIntoConstraints = false

        let yesButton:UIButton = UIButton()
        yesButton.backgroundColor = UIColor.init(red: 117/255, green: 218/255, blue: 152/255, alpha: 1)
        yesButton.setTitle("YES", for: .normal)
        yesButton.addTarget(self, action:#selector(self.yesButtonTapped), for: .touchUpInside)
        customAlert.addSubview(yesButton)
        yesButton.clipsToBounds = true
        yesButton.titleLabel?.font =  UIFont(name: "helvetica-bold", size: 15)
        yesButton.clipsToBounds = true
        yesButton.layer.cornerRadius = 8.0
        yesButton.layer.maskedCorners = [.layerMaxXMaxYCorner]
        yesButton.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints:[NSLayoutConstraint] = [
        
            customAlert.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            customAlert.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            customAlert.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            customAlert.widthAnchor.constraint(equalToConstant: 260),
            customAlert.heightAnchor.constraint(equalToConstant: 130),
            sensorImageView.leadingAnchor.constraint(equalTo: customAlert.leadingAnchor, constant: 8.0),
            sensorImageView.topAnchor.constraint(equalTo: customAlert.topAnchor, constant: 25.0),
            sensorImageView.heightAnchor.constraint(equalToConstant: 30.0),
            sensorImageView.widthAnchor.constraint(equalToConstant: 30.0),
            sensorMessageLabel.leadingAnchor.constraint(equalTo: sensorImageView.trailingAnchor, constant: 8),
            sensorMessageLabel.topAnchor.constraint(equalTo: customAlert.topAnchor, constant: 18.0),
            sensorMessageLabel.trailingAnchor.constraint(equalTo: customAlert.trailingAnchor, constant: 9.0),
            sensorMessageLabel.heightAnchor.constraint(equalToConstant: 44.0),
            noButton.leadingAnchor.constraint(equalTo: customAlert.leadingAnchor, constant: 0),
            noButton.bottomAnchor.constraint(equalTo: customAlert.bottomAnchor, constant: 0.0),
            noButton.widthAnchor.constraint(equalTo: customAlert.widthAnchor, multiplier: 0.5, constant: 0.0),
            noButton.heightAnchor.constraint(equalToConstant: 44.0),
            yesButton.trailingAnchor.constraint(equalTo: customAlert.trailingAnchor, constant: 0),
            yesButton.bottomAnchor.constraint(equalTo: customAlert.bottomAnchor, constant: 0.0),
            yesButton.widthAnchor.constraint(equalTo: customAlert.widthAnchor, multiplier: 0.5, constant: 0.0),
            yesButton.heightAnchor.constraint(equalToConstant: 44.0)

        ]
        
        NSLayoutConstraint.activate(constraints)
        
    
    }
    
    
    @objc func noButtonTapped() {
        
        self.view.endEditing(true)
        
        customAlert.isHidden = true
        coverView.isHidden = true

        
        let emailPassword = email + password
        
//        deviceThumb["ThumbInfo"] = emailPassword
        
        var deviceThumb = [String:Any]()
        deviceThumb["ThumbInfo"] = emailPassword
        deviceThumb["Status"] = false
        dataDictionary["UL_DeviceThumb"] = deviceThumb
        
        var createUserDictionary = [String : Any]()
        createUserDictionary["data"] = dataDictionary
        
        print("create user dictionary ", createUserDictionary)
        
        //
        let _:Bool = KeychainWrapper.standard.removeAllKeys()
        let _: Bool = KeychainWrapper.standard.set(emailPassword, forKey: "userPassword")
        
        
        blurView.isHidden = false
        spinner.isHidden = false
        spinner.startAnimate(spinnerType: SpinnerType.ballClipRotate, spinnercolor: UIColor.white, complete: nil)
        
        self.signUpService(dataDictionary: createUserDictionary, touch: false)
        
    }
    
    
    @objc func yesButtonTapped() {
        
        self.view.endEditing(true)
        
        let context = LAContext()
        
        var error: NSError?
        
        if context.canEvaluatePolicy(
            LAPolicy.deviceOwnerAuthenticationWithBiometrics,
            error: &error) {
            
            customAlert.isHidden = true
            
            coverView.isHidden = true
            let emailPassword = email + password
            
            var deviceThumb = [String:Any]()
            deviceThumb["ThumbInfo"] = emailPassword
            deviceThumb["Status"] = true
            
            dataDictionary["UL_DeviceThumb"] = deviceThumb
            
            var createUserDictionary = [String : Any]()
            createUserDictionary["data"] = dataDictionary
            
            //
            let _:Bool = KeychainWrapper.standard.removeAllKeys()
            let _: Bool = KeychainWrapper.standard.set(emailPassword, forKey: "userPassword")
            //
            
            self.view.endEditing(true)
            
            blurView.isHidden = false
            spinner.isHidden = false
            spinner.startAnimate(spinnerType: SpinnerType.ballClipRotate, spinnercolor: UIColor.white, complete: nil)
            
            self.signUpService(dataDictionary: createUserDictionary, touch: true)
            
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
