//
//  APIManager.swift
//  UniversalLogger
//
//  Created by Pushpank on 7/25/18.
//  Copyright © 2018 Cynoteck6. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

class APIManager {
    
    static let apiManager = APIManager()
    
    private init() {
        
        // Do nothing here
        
    }
    
    /*!
     **********************************************
     * @Author name Pushpank Kumar
     * @Date 25 July 2018
     * @Input Parameter url
     * @return error or data get from the server
     **********************************************
     */
    
    func callGetService(urlString:String, header:[String:String])->Promise<[String:Any]>  {
        let url = URL(string: urlString)
        
        return Promise { seal in
            
            Alamofire.request(url!, headers: header).validate()
                .responseJSON { response in
                    
                    switch response.result {
                    case .success(let json):
                        guard let json = json as? [String:Any] else {
                            return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                        }
                        
                        seal.fulfill(json)
                        
                    case .failure(let error):
                        seal.reject(error)
                    }
            }
        }
        
    }
    
    /*!
     **********************************************
     * @Author name Pushpank Kumar
     * @Date 25 July 2018
     * @Input Parameter url and a dictionary
     * @return error or data get from the server
     **********************************************
     */

    func callPostService(urlString:String, parameters:[String:Any], header:[String:String]) -> Promise<[String:Any]> {
        
        print(urlString)
        let url = URL(string: urlString)
        
        
        return Promise { seal in
            
            Alamofire.request(url!, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).validate().responseJSON { response  in
                
                switch response.result {
                    
                case .success(let json):
                    guard let json = json as? [String:Any] else {
                        return seal.reject(AFError.responseValidationFailed(reason: .dataFileNil))
                    }
                    
                    seal.fulfill(json)
                    
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
}
