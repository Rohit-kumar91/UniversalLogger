//
//  DashboardModel.swift
//  UniversalLogger
//
//  Created by Pushpank on 8/1/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import Foundation
import PromiseKit

class DatabaseInfoModel {
    
    init() {
        
        // Initilizer
        // Do Notihng here...
    }
    
    
    func getUserDatabaseAllEntries(dataDictionary: [String:Any], header:[String:String],userApi:Int)->Promise<[String:Any]> {
        return Promise { seal in
            
            var apiURl:String = String()
            
            if userApi == 0 {
                
                apiURl = "http://45.40.133.173:8097/api/User/GetUserDatabaseAllEntries"
                
            }else{
                
                apiURl = "http://45.40.133.173:8097/api/User/GetSupervisorUserDatabaseAllEntries"
            }

            
            
            APIManager.apiManager.callPostService(urlString: apiURl, parameters: dataDictionary, header: header).done{ json in
                
                seal.fulfill(json)
                
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
    
    
    
    // MARK: deleteDatabase Service Call
    func deleteDatabaseEntry(dataDictionary: [String:Any], header:[String:String])->Promise<[String:Any]> {
        return Promise { seal in
            
            let apiURl =  globalConstants.apiUrl.kBaseUrl + globalConstants.apiUrl.KDeleteDatabaseEntry
            print(apiURl)
            APIManager.apiManager.callPostService(urlString: apiURl, parameters: dataDictionary, header: header).done{ json in
                
                seal.fulfill(json)
                
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
    
    
    func getNewEntryInDatabase(dataDictionary: [String:Any], header:[String:String]) -> Promise<[String:Any]> {
        return Promise { seal in
            
            let apiURl =  globalConstants.apiUrl.kBaseUrl + globalConstants.apiUrl.KGetNewEntryInExistingDatabase
            print(apiURl)
            APIManager.apiManager.callPostService(urlString: apiURl, parameters: dataDictionary, header: header).done{ json in
                seal.fulfill(json)
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
    
    
    
}


