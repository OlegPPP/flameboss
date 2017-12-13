//
//  UserLogin.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 2/23/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation
import Gloss

public struct UserLogin : Gloss.Decodable
{
    let username: String
    let authToken: String
    
    public init?(json: JSON)
    {
        guard let username: String = "username" <~~ json,
        let authToken: String = "auth_token" <~~ json
        else { return nil }
        
        self.username = username
        self.authToken = authToken
    }
}
