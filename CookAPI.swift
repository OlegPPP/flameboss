//
//  CookAPI.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 6/16/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation

class CookAPI : NSObject
{
    public static func getUserCookHistory(completion: @escaping ([Cook]?, Error?) -> Void)
    {
        let urlEnding = "/api/v1/cooks"
        
        APICommon.runRequest(urlEnding: urlEnding, method: .GET) { (jsonDict, error) in
            guard error == nil else
            {
                completion(nil, APICommon.errorFromMessage((error?.localizedDescription)!))
                return
            }
            
            var cooks = [Cook]()
            if let arrayOfCookIndices = jsonDict?["dict"] as? [ [ String : AnyObject] ]
            {
                for cookJson in arrayOfCookIndices
                {
                    let cook = Cook(json: cookJson)
                    cooks.append(cook!)
                }
            }
        
            completion(cooks, nil)
        }
    }
    
    public static func getCook(cookID: Int, skipCount: Int = 0, completion: @escaping (Cook?, Error?) -> Void)
    {
        let urlEnding = "/api/v1/cooks/" + String(cookID) + "?skip_cnt=" + String(skipCount)
        
        APICommon.runRequest(urlEnding: urlEnding, method: .GET) { (json, error) in
            guard error == nil else
            {
                completion(nil, APICommon.errorFromMessage((error?.localizedDescription)!))
                return
            }
            
            guard let cook = Cook(json: json!) else
            {
                let message = "Could not get cook."
                completion(nil, APICommon.errorFromMessage(message))
                return
            }
            completion(cook, nil)
        }
    }
    
    public static func updateCook(cookID: Int, title: String = "", notes: String = "", keep: Bool = true,
                                  completion: @escaping (Error?) -> Void)
    {
        let urlEnding = "/api/v1/cooks/" + String(cookID)
        
        let body = "cook[title]=" + title + "&cook[notes]=" + notes + "&cook[keep]=" + String(keep)
        
        APICommon.runRequest(urlEnding: urlEnding, method: .PATCH, body: body) { (jsonDict, error) in
            
            if error != nil { completion(error); return }
            let result = APICommon.statusFromJsonDict(jsonDict!, errorMessage: "Could not updat cook.")
            completion(result)
        }
    }
    
    public static func deleteCook(cookID: UInt, completion: @escaping (Error?) -> Void)
    {
        let urlEnding = "/api/v1/cooks/" + String(cookID)
        
        APICommon.runRequest(urlEnding: urlEnding, method: .DELETE) { (jsonDict, error) in
            
            if error != nil { completion(error); return }
            let result = APICommon.statusFromJsonDict(jsonDict!, errorMessage: "Could not delete cook.")
            completion(result)
        }
    }
}
