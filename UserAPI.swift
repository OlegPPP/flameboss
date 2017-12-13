//
//  UserAPI.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 6/19/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation

class UserAPI : NSObject
{
    private static var apnToken : String = ""
    private static var username : String = ""
    private static var authToken : String = ""
    private static var user: User?
    
    public static func getUser() -> User?
    {
        return user
    }
    
    public static func initializeUser(completion: ((Error?) -> Void)?)
    {
        username = UserDataStore.getUsername()
        authToken = UserDataStore.getAuthToken()
        print("username \(username), authToken \(authToken)")
        
        fetchUserFromAPI { (user, error) in
            
            if let user = user
            {
                self.user = user
                if !apnToken.isEmpty
                {
                    sendApnToken(deviceId: 0, completion: { (error) in
                    })
                }
                completion?(error)
            }
            else { completion?(error) }
        }
    }
    
    public static func fetchUserFromAPI(completion: @escaping (User?, Error?) -> Void)
    {
        let urlEnding = "/api/v1/registration"
        
        APICommon.runRequest(urlEnding: urlEnding, method: .GET) { (jsonDict, error) in
            
            if error != nil
            {
                print("FB_API: getUser: error: \(error.debugDescription)")
                
                completion(nil, error)
                return
            }
            
            guard let user = User(json: jsonDict!)
                else
            {
                let message = "could not decode user"
                completion(nil, APICommon.errorFromMessage(message))
                return
            }
            
            print("FB_API: getUser OK")
            completion(user, nil)
        }
    }
    
    public static func updateUser(user: User, completion: @escaping (Error?) -> Void)
    {
        let urlEnding = "/api/v1/registration"
        let body = "registration[email]=\(user.email)&registration[terms_of_use]=true&registration[phone]=\(user.phone)&registration[texts_enabled]=\(user.texts_enabled)&registration[celsius]=\(user.celsius)"
        
        APICommon.runRequest(urlEnding: urlEnding, method: .PATCH, body: body) { (jsonDict, error) in
            
            if error != nil { completion(error); return }
            
            let result = APICommon.statusFromJsonDict(jsonDict!, errorMessage: "Could not update user.")
            
            if result == nil
            {
                self.user = user
                fetchUserFromAPI(completion: { (user, error) in
                    if error == nil { self.user = user }
                })
            }
            
            completion(result)
        }
    }
    
    public static func signUpUser(username: String, email: String, password: String,
                                  completion: @escaping (Error?) -> Void)
    {
        let urlEnding = "/api/v1/registrations"
        let urlBody = "registration[username]=" + username + "&registration[email]=" + email +
            "&registration[password]=" + password + "&registration[terms_of_use]=true"
        
        APICommon.runRequest(urlEnding: urlEnding, method: .POST, body: urlBody) { (jsonDict, error) in
            if error != nil { completion(error); return }
            
            guard let status = Status(json: jsonDict!) else
            {
                let message = "Could not sign up user"
                completion(APICommon.errorFromMessage(message))
                return
            }
            
            if status.message != "OK"
            {
                completion(APICommon.errorFromMessage(status.message))
                return
            }
            
            loginUser(username: username, password: password, completion: { (error) in
                completion(error)
            })
        }
    }
    
    public static func loginUser(username: String, password: String, completion: @escaping (Error?) -> Void)
    {
        let urlEnding = "/api/v1/sessions"
        let urlBody = "session[login]=" + username + "&session[password]=" + password
        
        APICommon.runRequest(urlEnding: urlEnding, method: .POST, body: urlBody) { (jsonDict, loginError) in
            
            if loginError != nil { completion(loginError); return }
            
            guard let loginResult = UserLogin(json: jsonDict!) else
            {
                let message = jsonDict!["message"] as! String
                completion(APICommon.errorFromMessage(message))
                return
            }
            
            self.username = loginResult.username
            self.authToken = loginResult.authToken
            
            UserDataWriter.saveUsername(self.username)
            UserDataWriter.saveAuthToken(self.authToken)
            
            initializeUser(completion: { (initializeError) in
                completion(initializeError)
            })
        }
    }
    
    public static func logoutCurrentUser(completion: @escaping (Error?) -> Void)
    {
        let urlEnding = "/api/v1/sessions"
        
        APICommon.runRequest(urlEnding: urlEnding, method: .DELETE) { (jsonDict, error) in
            
            // Log out user regardless if an error occurred
            UserDataWriter.removeUsernameAndAuthToken()
            self.user = nil
            
            if error != nil { completion(error); return }
            
            guard let status = Status(json: jsonDict!) else
            {
                let message = "Could not log out"
                completion(APICommon.errorFromMessage(message))
                return
            }
            
            if status.message != "OK"
            {
                completion(APICommon.errorFromMessage(status.message))
                return
            }
            
            completion(nil)
        }
    }
    
    public static func setApnToken(_ token : String)
    {
        print("set apn token: \(token)")
        apnToken = token
        if user != nil { sendApnToken(deviceId: 0) { (error) in } }
    }
    
    public static func sendApnToken(deviceId: UInt, completion: @escaping (Error?) -> Void)
    {
        let urlEnding : String = "/api/v1/apn_devices"
        let body : String = "apn_device[device_id]=" + String(deviceId) + "&apn_device[token]=" + apnToken
        
        APICommon.runRequest(urlEnding: urlEnding, method: .POST, body: body) { (jsonDict, error) in
            if error != nil
            {
                print(error.debugDescription)
                completion(error)
                return
            }
            print("FB_API: sendApnToken OK")
            completion(nil)
        }
    }
}
