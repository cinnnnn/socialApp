//
//  UserDefaultsExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 12.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static let extensions = UserDefaults(suiteName: "group.flavaNotificationExtension")!
    
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
