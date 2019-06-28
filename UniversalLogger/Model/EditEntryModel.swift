//
//  EditEntryModel.swift
//  UniversalLogger
//
//  Created by Rohit Prajapati on 16/11/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import UIKit
import PromiseKit

class EditEntryModel: NSObject {

    override init() {
        
        // Initilizer
        // Do Notihng here...
    }
    
    func saveDatabaseEntryAfterEdit (dataDictionary: [String:Any], header:[String:String])->Promise<[String:Any]> {
        return Promise { seal in
            
            let apiURl =  globalConstants.apiUrl.kBaseUrl + globalConstants.apiUrl.KSaveDatabaseEntryAfterEdit
            print(apiURl)
            
            APIManager.apiManager.callPostService(urlString: apiURl, parameters: dataDictionary, header: header).done{ json in
                
                seal.fulfill(json)
                
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
    
}
