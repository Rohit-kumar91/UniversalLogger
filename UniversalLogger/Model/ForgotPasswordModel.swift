//
//  ForgotPasswordModel.swift
//  UniversalLogger
//
//  Created by Pushpank on 7/26/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import Foundation
import PromiseKit



class ForgotPasswordModel {
    
    // Declarations
    var email: String!
    var alertMessage: String!
    
    // Initilizer
    init() {
        
        self.email = ""
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
    
    
    // Email Format Validate
    private func isValid(_ email: String) -> Bool {
        
        let emailRegEx = globalConstants.validation.kEmailFormat
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
        
    }
    
    
    /*!
     **********************************************
     * @Author name Pushpank Kumar
     * @Date 27 July 2018
     * @Input Parameter Json data and header
     If we get any response from server it will fulfil otherwise it will reject
     **********************************************
     */
    // MARK: forgot password Service Call

    func forgotPasswordService(dataDictionary: [String:Any], header:[String:String])->Promise<[String:Any]>  {
        
        return Promise { seal in
            
            let apiURl =  globalConstants.apiUrl.kBaseUrl + globalConstants.apiUrl.kForgotPassword
            APIManager.apiManager.callPostService(urlString: apiURl, parameters: dataDictionary, header: header).done{ json in
                
                seal.fulfill(json)
                
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
  
}
