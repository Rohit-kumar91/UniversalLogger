//
//  NewEntryModel.swift
//  UniversalLogger
//
//  Created by Cynoteck6 on 8/9/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import Foundation
import PromiseKit

class LinkSupervisorModel {
    
    init() {
        
        // Initilizer
        // do nothing here
    }
    
    /*!
     **********************************************
     * @Author name Pushpank Kumar
     * @Date 9 August 2018
     * @Input Parameter Json data and header
     If we get any response from server it will fulfil otherwise it will reject
     **********************************************
     */
    // MARK: GetAllUsers Service Call
    
    
    func linkDatabasetoSupervisor(dataDictionary: [String:Any], header:[String:String])->Promise<[String:Any]> {
        return Promise { seal in
            
            let apiURl =  "http://45.40.133.173:8097/api/User/LinkDatabasetoSupervisor"
            APIManager.apiManager.callPostService(urlString: apiURl, parameters: dataDictionary, header: header).done{ json in
                
                seal.fulfill(json)
                
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
   
}

