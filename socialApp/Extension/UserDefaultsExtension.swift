//
//  UserDefaultsExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 12.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static let extensions = UserDefaults(suiteName: "group.CY-07EB0D24-9283-11E7-ADF0-5718D65F0A41.com.cydia.Extender")!
    
    private enum Keys: String {
         case badge
    }
    
    var badge: Int {
        get {
            return UserDefaults.extensions.integer(forKey: Keys.badge.rawValue)
        }
        
        set {
            UserDefaults.extensions.set(newValue, forKey: Keys.badge.rawValue)
        }
    }
}
