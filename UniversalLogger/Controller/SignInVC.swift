//
//  ViewController.swift
//  UniversalLogger
//
//  Created by Pushpank on 7/24/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import UIKit
import PromiseKit
import SwiftyJSON
import LocalAuthentication
import SSSpinnerButton
import SwiftKeychainWrapper

class SignInVC: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet var loginContainerView: UIView!
    @IBOutlet var userProfileView: UIImageView!
    @IBOutlet var signInButtonOutlet: UIButton!
    @IBOutlet var signUpButtonOutlet: UIButton!
    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    @IBOutlet var blurView: UIView!
    @IBOutlet var spinner: SSSpinnerButton!
    @IBOutlet var userIconTopConstraint: NSLayoutConstraint!
    
    // local Declarations
    private lazy var singInObj: SignInModel = SignInModel()
    private lazy var blurView1 = UIView()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    // View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinner.isHidden = true
        
        // loginContainerView View customization
        loginContainerView.setBorder()
        
        // userProfileView View customization
        userProfileView.layer.borderColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1).cgColor
        userProfileView.layer.borderWidth = 7.0
        
        // signInButtonOutlet View customization
        signInButtonOutlet.buttonWithShadow()
        signUpButtonOutlet.titleLabel?.textColor = UIColor.init(red: 45/255, green: 57/255, blue: 73/255, alpha: 1.0)
        
        // sign in with Touch Id
        let fingerPrintEnabled = UserDefaults.standard.bool(forKey: globalConstants.touchSensor.kTouchSensor)
        
        if fingerPrintEnabled {
            
            blurView1.frame = self.view.frame
            blurView1.backgroundColor = UIColor.init(red: 183/255, green: 183/255, blue: 183/255, alpha: 0.9)
            self.view.addSubview(blurView1)
            blurView1.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            authenticateUsingTouchId()
        }
    }

    
    // view updates after view cycle calling
    // Called to notify the VC that its view has just laid out its subviews.
    
    override func viewDidLayoutSubviews() {
        
        userProfileView.layer.cornerRadius = userProfileView.frame.size.width/2
        userIconTopConstraint.constant = -((userProfileView.frame.size.height)/2)
       
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
            singInObj.email = emailTextfield.text
            passwordTextfield.becomeFirstResponder()

        }
        else if(textField == passwordTextfield)
        {
            singInObj.password = passwordTextfield.text
            passwordTextfield.resignFirstResponder()
        }
        return true
    }

    
    
    // MARK: Private function
    @IBAction func signInTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        var email = emailTextfield.text
        let password = passwordTextfield.text
        email = email?.trimmingCharacters(in: .whitespaces)
        
        singInObj.email = email
        singInObj.password = password
        
        if !singInObj.validateEmail()
        {
            
            AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: singInObj.alertMessage, actionTitles: [globalConstants.alertController.kOK], actions: nil)
            
        }
        else if !singInObj.validatePassword()
        {
            
            AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: singInObj.alertMessage, actionTitles: [globalConstants.alertController.kOK], actions: nil)
            
        } else {

            var userDictionary = [String : Any]()
            userDictionary[globalConstants.apiUrl.kEmaiIId] = email
            userDictionary[globalConstants.apiUrl.kPassword] = password
            userDictionary[globalConstants.apiUrl.kDevice_ID] = appDelegate.deviceID
            
            var dataDictionary = [String:Any]()
            dataDictionary[globalConstants.apiUrl.kUserLoginType] = 1
            dataDictionary[globalConstants.apiUrl.kUL_Users] = userDictionary

            var signInDictionary = [String:Any]()
            signInDictionary[globalConstants.apiUrl.kData] = dataDictionary
            
            
            
            print("Dict sskadflajsdlkfjl===\(signInDictionary)")
            // user signIn service call
            self.userSignInService(dataDictionary: signInDictionary)
            
            //
            let emailPassword = email! + password!
            let _:Bool = KeychainWrapper.standard.removeAllKeys()
            let _: Bool = KeychainWrapper.standard.set(emailPassword, forKey: "userPassword")
            //

            // handle spinner
            blurView.isHidden = false
            spinner.isHidden = false
            spinner.startAnimate(spinnerType: SpinnerType.ballClipRotate, spinnercolor: UIColor.white, complete: nil)
            
        }
        
    }
    
    // Forgot Password Button
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {

        self.performSegue(withIdentifier: globalConstants.stroryboard.stroryboardSegueId.kForgotPassword, sender: nil)
  
    }
    
    // MARK: User signIn Web Service Handler
    func userSignInService(dataDictionary:[String:Any]) {
        
        let headers = [ "Content-Type": "application/json" ]
        
        singInObj.userSignIn(dataDictionary: dataDictionary, header: headers).done { json-> Void in
            
            // stop spinner
            self.spinner.stopAnimate(complete: {
                self.blurView.isHidden = true
                self.spinner.isHidden = true
            })
            
            let jsonDictionary = JSON(json)
            
            print("json ", json)
            let responseStatus = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseStatus].boolValue
            
            if responseStatus {
                
                let token = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kToken].stringValue
                
                UserDefaults.standard.set(token, forKey: "token")

                self.performSegue(withIdentifier: "ShowDatabaseID", sender: nil)
                
            } else {
                
                let responseMessage = jsonDictionary[globalConstants.apiUrl.kResponse][globalConstants.apiUrl.kResponseMessage].stringValue
                
                
                let userIdType = jsonDictionary["data"]["UserLoginType"].intValue
                
                if userIdType == 2 {
                    DispatchQueue.main.async {
                        
                        self.blurView1.isHidden = false
                        
                    }
                    
                    let alertController = UIAlertController(title:globalConstants.alertController.kAlertTitle, message:responseMessage, preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(UIAlertAction(title: globalConstants.alertController.kOK, style: .default, handler: { _ in
                        
                        self.authenticateUsingTouchId()

                    }))
 
                    self.present(alertController, animated: true, completion: nil)

                    
                } else {
                    
                    AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: responseMessage, actionTitles: ["OK"], actions: nil)
                }
                
            }
            
            }.catch { error in
                
                self.spinner.stopAnimate(complete: {
                    self.blurView.isHidden = true
                    self.spinner.isHidden = true
                })
                
                AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: error.localizedDescription, actionTitles: [globalConstants.alertController.kOK], actions: nil)
        }
    }
    
    
    
    // Segue Handle
    // MARK: StoryboardSegue
    @IBAction func unwindToSignUp(segue:UIStoryboardSegue) {
        
        // Do nothing here
        // its use for exit from another VC
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        emailTextfield.text = ""
        passwordTextfield.text = ""
    }
    

    /*!
     **********************************************
     * @Author name Pushpank Kumar
     * @Date 24 May 2018
     * Authenticate with Touch ID
     **********************************************
     */
    
    // MARK: Touch Sensor handle
    func authenticateUsingTouchId() {
        
        let authContext:LAContext = LAContext()
        let authReason:String = globalConstants.touchSensor.kAuthReason
        var authError:NSError?
        
        if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            
            authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: authReason) { (wasSuccessful, Error) in
                
                if wasSuccessful {

                    DispatchQueue.main.async {
                        
                        self.blurView1.isHidden = true
                        
                    }
 
                    let thumbInfo: String? = KeychainWrapper.standard.string(forKey: "userPassword")
                    
                    print("Thumb info for all \(String(describing: thumbInfo))")

                    var dataDictionary = [String:Any]()
                    dataDictionary["UserLoginType"] = 3
                    
                    var userDictionary = [String : Any]()
                    userDictionary["ThumbInfo"] = thumbInfo
                    dataDictionary["UL_DeviceThumb"] = userDictionary
                    
                    var signInDictionary = [String:Any]()
                    signInDictionary[globalConstants.apiUrl.kData] = dataDictionary
                    print("asdjflkajsdlkfjlasdjlkf \(signInDictionary)")
                    
                    
                    self.userSignInService(dataDictionary: signInDictionary)
                    
                    DispatchQueue.main.async {
                        
                        self.blurView.isHidden = false
                        self.spinner.isHidden = false
                        self.spinner.startAnimate(spinnerType: SpinnerType.ballClipRotate, spinnercolor: UIColor.white, complete: nil)
                    }
                } else {
                    
                    if let error = Error {
                        
                        let message = self.reportTouchIDError(error: error as NSError)
                        print("error is ", message)
                        
                        if message == "user tapped enter password" {
                            
                            self.showAlertWithPassword()
                            
                        } else if message == "user cancel auth" {
                            
                            self.authenticateUsingTouchId()
                            
                        }

                    }
                }
            }
        } else {
            
            AlertController.sharedInstance.showAlertView(title: globalConstants.alertController.kAlertTitle, message: (authError?.localizedDescription)!, actionTitles: [globalConstants.alertController.kOK], actions: nil)
        }
    }
    
    
    func showAlertWithPassword()  {
        
        let alertController = UIAlertController(title: globalConstants.alertController.kAlertTitle, message: globalConstants.alertController.kAlertSubtitleForPassword, preferredStyle: .alert)
        
        alertController.addTextField {
           
            textField in
            
            textField.placeholder = globalConstants.apiUrl.kPassword
            textField.isSecureTextEntry = true
        }
        
        let action = UIAlertAction(title: globalConstants.alertController.kOK, style: .default) {
            
            [weak alertController] _ in
            
            guard let alertController = alertController, let textField = alertController.textFields?.first else { return }
            
            var dataDictionary = [String:Any]()
            
            var userDict = [String : Any]()
            userDict[globalConstants.apiUrl.kPassword] = textField.text
            
            
            if  let retrievedPassword: String = KeychainWrapper.standard.string(forKey: "userPassword"){
                
                var userDictionary = [String : Any]()
                userDictionary["ThumbInfo"] = retrievedPassword
                dataDictionary["UserLoginType"] = 2
                dataDictionary["UL_Users"] = userDict
                dataDictionary["UL_DeviceThumb"] = userDictionary
                
                
                print("data dict is ===\(dataDictionary)")
                
                var signInDictionary = [String:Any]()
                signInDictionary[globalConstants.apiUrl.kData] = dataDictionary
                
                print("signInDictionary dict is ===\(signInDictionary)")

                self.userSignInService(dataDictionary: signInDictionary)
                
                DispatchQueue.main.async {
                    
                    self.blurView1.isHidden = true
                }
                
                DispatchQueue.main.async {
                    
                    self.blurView.isHidden = false
                    self.spinner.isHidden = false
                    self.spinner.startAnimate(spinnerType: SpinnerType.ballClipRotate, spinnercolor: UIColor.white, complete: nil)
                }
                
            } else{
                
                print("Retrieved passwork is:")
                
            }
        }
        
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    
    /*!
     **********************************************
     * @Author name Pushpank Kumar
     * @Date 18 May 2018
     * @Input Parameter Error Message
     **********************************************
     */
    
    func reportTouchIDError(error:NSError) ->String  {
        var message:String = ""
        switch error.code {
        case LAError.appCancel.rawValue:
            message = "Authentication was cancel by application"
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide the valid credentials"
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
        case LAError.systemCancel.rawValue:
            message = "Authentication was canceled by the system"
        case LAError.userCancel.rawValue:
            message = "user cancel auth"
        case LAError.userFallback.rawValue:
            message = "user tapped enter password"
        default:
            message = error.localizedDescription
        }
        
        return message
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

