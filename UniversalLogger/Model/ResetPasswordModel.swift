//
//  ResetPasswordModel.swift
//  UniversalLogger
//
//  Created by Pushpank on 7/28/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import Foundation
import PromiseKit

class ResetPasswordModel {
    
    // Declarations
    var currentPassword: String!
    var newPassword: String!
    var confirmPassword: String!
    var alertMessage: String!
    var userEmail: String!
    var forgotpassword: String = String()
    
    // Initilizer
    init() {
        
        self.currentPassword = ""
        self.newPassword = ""
        self.confirmPassword = ""
        self.userEmail = ""
        self.alertMessage = ""
    }
    
    
    //MARK: Validation
    // Password Validate
    func validatePassword () -> Bool
    {

        var valid: Bool = true
        
        if self.currentPassword.isEmpty {
            
            valid = false
            self.alertMessage = globalConstants.validation.kCurrentPasswordAlert
   
        }
        else if self.newPassword.isEmpty {
            
            valid = false
            self.alertMessage =  globalConstants.validation.kNewPasswordAlert

        }
        else if self.newPassword.count < 8 {
            
            valid = false
            self.alertMessage = globalConstants.validation.kPasswordLengthValidation
            
        }
        else if self.confirmPassword.isEmpty {
            
            valid = false
            self.alertMessage = globalConstants.validation.kConfirmPasswordAlert

        }

        else if self.newPassword != self.confirmPassword {
            
            valid = false
            self.alertMessage = globalConstants.validation.kPasswordNotSame
        }
        
        return valid
    }
    
    /*!
     **********************************************
     * @Author name Pushpank Kumar
     * @Date 28 July 2018
     * @Input Parameter Json data and header
     If we get any response from server it will fulfil otherwise it will reject
     **********************************************
     */
    // MARK: Reset password Service Call
    func resetPasswordService(dataDictionary: [String:Any], header:[String:String])->Promise<[String:Any]>  {
        
        return Promise { seal in
            
            let apiURl =  globalConstants.apiUrl.kBaseUrl + globalConstants.apiUrl.kChangePassword
            APIManager.apiManager.callPostService(urlString: apiURl, parameters: dataDictionary, header: header).done{ json in
    
                seal.fulfill(json)
                
                }.catch { error in
                    seal.reject(error)
            }
        }
    }

}
