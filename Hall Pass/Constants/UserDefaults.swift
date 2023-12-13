//
//  UserDefaults.swift
//  Break Tracker
//
//  Created by Ali Murad on 11/12/2023.
//

import Foundation

extension UserDefaults {
    
    var sessionID: String? {
        get {
            UserDefaults.standard.string(forKey: "sessionID")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "sessionID")
        }
    }
   
    
}
