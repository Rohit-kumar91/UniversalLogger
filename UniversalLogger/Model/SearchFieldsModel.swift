//
//  SearchFieldsModel.swift
//  UniversalLogger
//
//  Created by Rohit Prajapati on 09/01/19.
//  Copyright © 2019 Cynoteck6. All rights reserved.
//

import UIKit
import PromiseKit

class SearchFieldsModel: NSObject {

    override init() {
        
        // Initilizer
        // Do Notihng here...
    }
    
    
    func saveSubCategory (dataDictionary: [String:Any], header:[String:String])->Promise<[String:Any]> {
        
        print(dataDictionary)
        
        return Promise { seal in
            
            let apiURl =  globalConstants.apiUrl.kBaseUrl + globalConstants.apiUrl.KSaveSubCategory
            print(apiURl)
            
            APIManager.apiManager.callPostService(urlString: apiURl, parameters: dataDictionary, header: header).done{ json in
                
                seal.fulfill(json)
                
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
}
