//
//  Int.swift
//  FlameBoss
//
//  Created by Kevoye Boswell on 5/5/17.
//  Copyright © 2017 Collins Research Inc. All rights reserved.
//

import Foundation

extension Int
{
    // Converts tenths degrees celsius to fahrenheit, rounded. 
    // Zero is a special value meaning unknown
    var tdcToFahrenheit: Int { if (self == 0) { return 0 } else { return (self * 9 + 25) / 50 + 32 }}
    
    // Convert fahrenheit to tenths degrees celsius
    var fahrenheitToTdc: Int { if (self == 0) { return 0 } else { return ((self - 32) * 50 + 4) / 9 }}
    
    // Converts tenths degrees celsius to fahrenheit, rounded
    var tdcToCelsius: Int { return Int(round(Double(self)/10.0)) }
    
    // Converts celsius to tenth degree celsius
    var celsiusToTdc: Int { return self*10 }
    
    // Converts from fahrenheit to celsius
    var fahrenheitToCelsius: Int { return Int(round((Double(self) - 32) * (5.0/9.0))) }
    
    // Converts from celsius to fahrenheit
    var celsiusToFahrenheit: Int { return Int((Double(self) * (9.0/5.0) + 32)) }
}
