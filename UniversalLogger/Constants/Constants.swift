//
//  Constants.swift
//  UniversalLogger
//
//  Created by Cynoteck6 on 7/25/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import Foundation

struct globalConstants {
    
    struct validation {
        
        static let kEmailValidation = "Please enter your email address "
        
        static let kEmailFormatValidation = "Email address is not valid"
        
        static let kPasswordValidation = "Please enter a password"
        
        static let kPasswordLengthValidation = "Please enter a password with at least 8 characters"
        
        static let kPasswordNotSame = "New password and confirm password are not same."
        
        static let kEmptyDBAlert = "Please enter database name"
        
        static let kSelectOneCategoryAlert = "Please select at least one category"

        static let kEmailFormat =  "(?:[a-zA-Z0-9!#$%\\&‘*+/=?\\^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%\\&'*+/=?\\^_`{|}" +
            "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" +
            "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-" +
            "z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5" +
            "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" +
            "9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" +
        "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        static let kCategoryAlreadyExist = "Category is already exist"
        
        static let kBlankCategory = "Please enter a category name"
        
        static let kPasswordAndConfirmPasswordAlert = "Password and Confirm Password are not same."
        
        static let kCurrentPasswordAlert = "Please enter your current password."
        
        static let kNewPasswordAlert = "Please enter new password."
        
        static let kConfirmPasswordAlert = "Please eneter a confirm password."
        
        static let KSubCategoryBlankMessage = "Please select at least one sub category."

   
    }
    
    struct alertController {
        
        static let kOK = "OK"
        
        static let kCancel = "Cancel"
        
        static let kAlertTitle = "Universal Logger"
        
        static let kAlertSubtitleForPassword = "Please enter password here."
    }
    
    struct sliderArray {
        
        static let kSliderArray = ["Terms & Condition","Privacy Policy","Help","Logout","Touch ID"]
        
        
    }
    
    struct sliderImageArray {
        
        static let kSliderImageArray = ["terms","privacy","help","logout","touch"]
        
    }

    
    struct apiUrl {
        
        static let kBaseUrl = "http://45.40.133.173:8097/api/User/"

        static let kCreateUser = "CreateUser"
        
        static let kLogin = "Login"
        
        static let kEmaiIId = "EmaiIId"
        
        static let kPassword = "Password"
        
        static let kDevice_ID = "Device_ID"
        
        static let kUserLoginType = "UserLoginType"
        
        static let kUL_Users = "UL_Users"
        
        static let kResponseStatus = "ResponseStatus"
        
        static let kData = "data"
        
        static let kResponse = "response"
        
        static let kResponseMessage = "ResponseMessage"
        
        static let kToken = "Token"
        
        static let kForgotPassword = "ForgetPassword"
        
        static let kChangePassword = "ChangePassword"
        
        static let kGetAllUserDataBase = "GetAllUserDataBase"
        
        static let kGetULNewEntryDB = "GetULNewEntryDB"
        
        static let kCreateUserDatabase = "CreateUserDatabase"
        
        static let kDatabaseName = "DatabaseName"
        
        static let kULRDB = "ULRDB"
        
        static let kULStaticCategory = "ULStaticCategory"
        
        static let kUL_Category = "UL_Category"
        
        static let kSFieldName = "SFieldName"
        
        static let kCategoryName = "CategoryName"
        
        static let kUL_StaticCategory = "UL_StaticCategory"
        
        static let kResponseCode = "ResponseCode"
        
        static let kUL_RDB = "UL_RDB"
        
        static let kSaveEntryDatabase = "SaveEntryDatabase"
        
        static let kDatabaseID = "DatabaseID"
        
        static let kResponseCodeValue = 200
        
        static let kGetSupervisorDatabase = "GetSupervisorDatabase"
        
        static let kSendDatabaseAllEntries = "SendDatabaseAllEntries"
        
        static let KDeleteDatabase = "DeleteDatabase"

        static let KDeleteDatabaseEntry = "DeleteDatabaseEntry"
        
        static let KGetDatabaseEntryForEdit = "GetDatabaseEntryForEdit"
        
        static let KCreateDatabaseEntryAfterEdit  = "CreateDatabaseEntryAfterEdit"
        
        static let KSaveDatabaseEntryAfterEdit  = "SaveDatabaseEntryAfterEdit"
        
        static let KGetNewEntryInExistingDatabase = "GetNewEntryInExistingDatabase"
        
        static let KSaveSubCategory = "SaveSubCategory"

    }
    
    struct touchSensor  {
        
        static let kTouchSensor = "touchSensor"
        
        static let kAuthReason = "Please use Touch ID to sign in Universal Logger"
    }
    
    struct  stroryboard {
        
        struct stroryboardId {
            
        }
        
        struct stroryboardSegueId {
            
            static let kDashboard = "dashboardVCId"
            
            static let kForgotPassword = "forgotPasswordID"
            
            static let kNewEntryVC = "newEntryId"
            
            // newEntryId
  
        }
    }
    
    
    struct inAppKeys {
        static let key_bundleId = "com.developmentRetroApp"
        static let key_SharedSecret = "d99d74cd2cd64204a0e8fa1230754e72"
    }
    
    
}

