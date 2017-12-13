//
//  User.swift
//  FlameBoss
//
//  Created by Roger Collins on 3/29/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation
import Gloss

public struct User : Gloss.Decodable
{
    var id: Int
    var username: String
    var email: String
    var terms_of_use: Bool!
    var confirmation_sent_at: String!
    var confirmed_at: String?
    var phone: String = ""
    var texts_enabled: Bool!
    var text_confirmation_sent_at: String?
    var text_confirmed_at: String!
    var celsius: Bool
    var tempScale: TempScale
    {
        return celsius ? .Celsius : .Fahrenheit
    }
    
    public init?(json: JSON)
    {
        guard let username: String = "username" <~~ json,
            let id: Int = "id" <~~ json,
            let email: String = "email" <~~ json,
            let terms_of_use: Bool = "terms_of_use" <~~ json,
            let confirmation_sent_at: String = "confirmation_sent_at" <~~ json,
            let texts_enabled: Bool = "texts_enabled" <~~ json,
            let celsius: Bool = "celsius" <~~ json
        else { return nil }
        
        text_confirmation_sent_at = "text_confirmation_sent_at" <~~ json
        text_confirmed_at = "text_confirmed_at" <~~ json
        phone = ("phone" <~~ json) ?? ""
        confirmed_at = "confirmed_at" <~~ json
    
        self.id = id
        self.username = username
        self.email = email
        self.terms_of_use = terms_of_use
        self.confirmation_sent_at = confirmation_sent_at
        self.texts_enabled = texts_enabled
        self.celsius = celsius
    }
}

enum TempScale
{
    case Fahrenheit
    case Celsius
}






