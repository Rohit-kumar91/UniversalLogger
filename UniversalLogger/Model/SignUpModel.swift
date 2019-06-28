//
//  SignUpModel.swift
//  UniversalLogger
//
//  Created by Pushpank on 7/25/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import Foundation
import PromiseKit


class SignUpModel {
    
    // Declarations
    var email: String!
    var password: String!
    var confirmPassword: String!
    var alertMessage: String!
    
    // Initilizer
    init() {
        
        self.email = ""
        self.password = ""
        self.confirmPassword = ""
        self.alertMessage = ""
    }
    
    //MARK: Validation
    // Email Validate
    func validateEmail () -> Bool
    {
        var valid: Bool = true
        
        if self.email.isEmpty
        {
            valid = false
            self.alertMessage = globalConstants.validation.kEmailValidation
        }
        else if !self.isValid(email) {
            
            valid = false
            self.alertMessage = globalConstants.validation.kEmailFormatValidation
            
        } else {
            
            valid = true
        }
        
        return valid
    }
    
    
    // Password Validate
    func validatePassword () -> Bool
    {

        var valid: Bool = true
        
        if self.password.isEmpty
        {
            valid = false
            self.alertMessage = globalConstants.validation.kPasswordValidation
        }
        else if self.password.count < 8 {
            
            valid = false
            self.alertMessage = globalConstants.validation.kPasswordLengthValidation
            
        }
        else if self.confirmPassword != self.password {
            
            valid = false
            self.alertMessage = globalConstants.validation.kPasswordAndConfirmPasswordAlert
            
        } else {
            
            valid = true
        }
        
        return valid
    }
    
    // Email Format Validate
    private func isValid(_ email: String) -> Bool {
        
        let emailRegEx = globalConstants.validation.kEmailFormat
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
        
    }
    
    /*!
     **********************************************
     * @Author name Pushpank Kumar
     * @Date 26 July 2018
     * @Input Parameter Json data and header
     If we get any response from server it will fulfil otherwise it will reject
     **********************************************
     */
    // MARK: User sign up in Service Call

    func userSignUp(dataDictionary:[String:Any], header:[String:String])->Promise<[String:Any]>  {
        
        return Promise { seal in
            
            let apiURl =  globalConstants.apiUrl.kBaseUrl + globalConstants.apiUrl.kCreateUser
            APIManager.apiManager.callPostService(urlString: apiURl, parameters: dataDictionary, header: header).done{ json in
                
                seal.fulfill(json)
                
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
    
}
