//
//  NewEntryModel.swift
//  UniversalLogger
//
//  Created by Cynoteck6 on 8/9/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import Foundation
import PromiseKit

class NewEntryModel {
    
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
    
    func saveEntryDatabase(dataDictionary: [String:Any], header:[String:String])->Promise<[String:Any]> {
        return Promise { seal in
            
            let apiURl =  globalConstants.apiUrl.kBaseUrl + globalConstants.apiUrl.kSaveEntryDatabase
            APIManager.apiManager.callPostService(urlString: apiURl, parameters: dataDictionary, header: header).done{ json in
                
                seal.fulfill(json)
                
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
}

