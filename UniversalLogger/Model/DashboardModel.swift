//
//  DashboardModel.swift
//  UniversalLogger
//
//  Created by Pushpank on 8/1/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import Foundation
import PromiseKit

class DashboardModel {
    
    init() {
        
        // Initilizer
        // Do Notihng here...
    }
    
    /*!
     **********************************************
     * @Author name Pushpank Kumar
     * @Date 1 August 2018
     * @Input Parameter Json data and header
     If we get any response from server it will fulfil otherwise it will reject
     **********************************************
     */
    // MARK: GetAllUsers Service Call
    
    func getAllUserDataBase(dataDictionary: [String:Any], header:[String:String])->Promise<[String:Any]> {
        return Promise { seal in
            
            let apiURl =  globalConstants.apiUrl.kBaseUrl + globalConstants.apiUrl.kGetAllUserDataBase
            
            print(apiURl)
            APIManager.apiManager.callPostService(urlString: apiURl, parameters: dataDictionary, header: header).done{ json in
                
                seal.fulfill(json)
                
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
    
    
    
    // MARK: getSupervisorDatabase Service Call
    
    func getSupervisorDatabase(dataDictionary: [String:Any], header:[String:String])->Promise<[String:Any]> {
        return Promise { seal in
            
            
            let apiURl = globalConstants.apiUrl.kBaseUrl + globalConstants.apiUrl.kGetSupervisorDatabase
            APIManager.apiManager.callPostService(urlString: apiURl, parameters: dataDictionary, header: header).done{ json in
                
                seal.fulfill(json)
                
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
    
    // MARK: sendDatabase Service Call
    
    func sendDatabase(dataDictionary: [String:Any], header:[String:String])->Promise<[String:Any]> {
        return Promise { seal in
            
            let apiURl =  globalConstants.apiUrl.kBaseUrl + globalConstants.apiUrl.kSendDatabaseAllEntries
            
            print(apiURl)
            
            APIManager.apiManager.callPostService(urlString: apiURl, parameters: dataDictionary, header: header).done{ json in
                
                seal.fulfill(json)
                
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
    
    
    // MARK: deleteDatabase Service Call
    func deleteDatabase(dataDictionary: [String:Any], header:[String:String])->Promise<[String:Any]> {
        return Promise { seal in
            
            let apiURl =  globalConstants.apiUrl.kBaseUrl + globalConstants.apiUrl.KDeleteDatabase
            print(apiURl)
            APIManager.apiManager.callPostService(urlString: apiURl, parameters: dataDictionary, header: header).done{ json in
                
                seal.fulfill(json)
                
                }.catch { error in
                    seal.reject(error)
            }
        }
    }
    
    
    
}
    
    



