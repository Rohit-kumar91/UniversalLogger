//
//  NewDatabaseModel.swift
//  UniversalLogger
//
//  Created by Cynoteck6 on 8/6/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import Foundation
import PromiseKit

class NewDatabaseModel {
    
    init() {
        
        // Initilizer
        // do nothing here 
    }
    
    /*!
     **********************************************
     * @Author name Pushpank Kumar
     * @Date 6 August 2018
     * @Input Parameter Json data and header
     If we get any response from server it will fulfil otherwise it will reject
     **********************************************
     */
    // MARK: GetAllUsers Service Call
    
    func getULNewEntryDB(header:[String:String])->Promise<[String:Any]> {
        return Promise { seal in
            
            let apiURl =  globalConstants.apiUrl.kBaseUrl + globalConstants.apiUrl.kGetULNewEntryDB
            
            APIManager.apiManager.callGetService(urlString: apiURl, header: header).done{ json in
                
                seal.fulfill(json)
                
                }.catch { error in
                    
                    seal.reject(error)
            }
        }
    }
    
    
    /*!
     **********************************************
     * @Author name Pushpank Kumar
     * @Date 6 August 2018
     * @Input Parameter Json data and header
     If we get any response from server it will fulfil otherwise it will reject
     **********************************************
     */
    // MARK: CreateUserDatabase Service Call
    
    func createUserDatabase(dataDictionary:[String:Any], header:[String:String])->Promise<[String:Any]> {
        
        
        return Promise { seal in
            
            let apiURl =  globalConstants.apiUrl.kBaseUrl + globalConstants.apiUrl.kCreateUserDatabase
            
            APIManager.apiManager.callPostService(urlString: apiURl, parameters: dataDictionary, header: header).done{ json in
                
                seal.fulfill(json)
                
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
}

