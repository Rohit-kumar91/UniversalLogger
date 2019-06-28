//
//  EditDatabaseInfoVCModel.swift
//  UniversalLogger
//
//  Created by Rohit Prajapati on 10/11/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import UIKit
import PromiseKit

class EditDatabaseInfoVCModel: NSObject {
    
    override init() {
        
        // Initilizer
        // Do Notihng here...
    }
    
    
    // MARK: GetDatabaseEntryForEdit Service Call
    func getDatabaseEntryForEdit(dataDictionary: [String:Any], header:[String:String])->Promise<[String:Any]> {
        return Promise { seal in
            
            let apiURl =  globalConstants.apiUrl.kBaseUrl + globalConstants.apiUrl.KGetDatabaseEntryForEdit
            print(apiURl)
            
            APIManager.apiManager.callPostService(urlString: apiURl, parameters: dataDictionary, header: header).done{ json in
                
                seal.fulfill(json)
                
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
    
    
    func createDatabaseEntryAfterEdit(dataDictionary: [String:Any], header:[String:String])->Promise<[String:Any]> {
        return Promise { seal in
            
            let apiURl =  globalConstants.apiUrl.kBaseUrl + globalConstants.apiUrl.KCreateDatabaseEntryAfterEdit
            print(apiURl)
            
            APIManager.apiManager.callPostService(urlString: apiURl, parameters: dataDictionary, header: header).done{ json in
                
                seal.fulfill(json)
                
                }.catch { error in
                    seal.reject(error)
            }
        }
    }

}
