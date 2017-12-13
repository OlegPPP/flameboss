//
//  APICommon.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 6/16/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation
import Gloss

class APICommon : NSObject
{
    private static let queue = DispatchQueue(label: "com.flameboss.comms")
    private static var apiVersion : String = "2"
    private static var apnToken : String = ""
    private static var username : String {
        get{
            return UserDataStore.getUsername()
        }
    }
    
    private static var authToken : String {
        get{
            return UserDataStore.getAuthToken()
        }
    }
    
    private static let serverURLs : [String] = ["https://myflameboss.com",
                                                "https://dev.myflameboss.com",
                                                "http://localhost:3000"]
    private static let wsURLs : [String] = ["wss://myflameboss.com/websocket",
                                            "wss://dev.myflameboss.com/websocket",
                                            "ws://localhost:3000/websocket"]

    
    public static func statusFromJsonDict(_ jsonDict: [String: AnyObject], errorMessage: String) -> NSError?
    {
        guard let status = Status(json: jsonDict)
            else { return APICommon.errorFromMessage(errorMessage) }
        
        if status.message != "OK" { return APICommon.errorFromMessage(status.message) }
        
        return nil
    }
    
    public static func runRequest(urlEnding: String, method: HTTPMethod, body: String = "",
                                   completion: @escaping ([String: AnyObject]?, Error?) -> Void)
    {
        queue.async {
            queue.suspend()
            print(serverURL() + urlEnding)
            let url = URL(string: serverURL() + urlEnding)
            let bodyData = body.data(using: String.Encoding.ascii, allowLossyConversion: true)

            loadJsonFromURL(url!, method: method, body: bodyData) { (jsonDict, error) in
                if error != nil {
                    print("FB_API: error: \(String(describing: error))")
                }
                completion(jsonDict, error)
                queue.resume()
            }
        }
    }
    
    public static func serverURL() -> String
    {
        return serverURLs[UserDataStore.getServerIndex()]
    }

    public static func wsRails() -> WsRails
    {
        return WsRails(url: wsURLs[UserDataStore.getServerIndex()])
    }
    
    private static func jsonFromData(_ data: Data) -> [String: AnyObject]?
    {
        // API could return a json dictionary
        if let jsonDict = getJsonDictionaryFromData(data)
        {
            return jsonDict
        }
        
        // or an array of json dictionaries
        if let jsonArray = getJsonArrayFromData(data)
        {
            let jsonDict = [ "dict" : jsonArray ]
            return jsonDict as [String : AnyObject]?
        }
        
        return nil
    }
    
    private static func loadJsonFromURL(_ url: URL, method: HTTPMethod, body: Data? = nil,
                                        completion: @escaping ([String: AnyObject]?, Error?) -> Void)
    {
        let session = URLSession.shared
        let request = NSMutableURLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(username, forHTTPHeaderField: "X-API-USERNAME")
        request.setValue(authToken, forHTTPHeaderField: "X-API-TOKEN")
        request.setValue(apiVersion, forHTTPHeaderField: "X-API-VERSION")
        if body != nil {
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
        request.httpMethod = method.rawValue
        request.httpBody = body
        
        let dataTask = session.dataTask(with: request as URLRequest)
        { (data, response, error) in
            
            if let responseError = error
            { completion(nil, responseError) }
                
            else if let httpResponse = response as? HTTPURLResponse
            {
                if httpResponse.statusCode != 200
                { completion(nil, httpResponseError(url: url, response: httpResponse)) }
                    
                else
                {
                    // API could return a json dictionary
                    if let jsonDict = jsonFromData(data!)
                    {
                        completion(jsonDict, nil)
                        return
                    }
                    
                    completion(nil, errorFromMessage(data!.description))
                }
            }
        }
        dataTask.resume()
    }
    
    public static func errorFromMessage(_ message: String) -> NSError
    {
        let description = [NSLocalizedDescriptionKey : message]
        let decodingError = NSError(domain: "com.collinsresearch", code: 0, userInfo: description)
        
        return decodingError
    }
    
    private static func httpResponseError(url: URL, response : HTTPURLResponse) -> NSError
    {
        let responseError = NSError(domain: "com.collinsresearch", code: response.statusCode,
                                    userInfo: [NSLocalizedDescriptionKey : url.debugDescription + ": status \(response.statusCode)"])
        
        return responseError
    }
    
    private static func getJsonDictionaryFromData(_ data: Data) -> [String : AnyObject]?
    {
        var json : [String : AnyObject]!
        do
        {
            json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                as? [String: AnyObject]
            return json
        }
        catch { return nil }
    }
    
    private static func getJsonArrayFromData(_ data: Data) -> [ [String : AnyObject] ]?
    {
        var json : [[String : AnyObject]]!
        do
        {
            json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
                as? [[String: AnyObject]]
            return json
        }
        catch { return nil }
    }
}

public enum HTTPMethod : String
{
    case POST = "POST"
    case GET = "GET"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
}

public struct Status : Gloss.Decodable
{
    public let message: String
    public init?(json: JSON)
    {
        self.message = ("message" <~~ json)!
    }
}
