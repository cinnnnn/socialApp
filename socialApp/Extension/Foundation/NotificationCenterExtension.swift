//
//  NotificationCenterExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 18.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

extension NotificationCenter {
    static func postCurrentUserNeedUpdate() {
        NotificationCenter.default.post(name: NSNotification.Name("currentUser"), object: nil)
    }
    
    static func postPremiumUpdate() {
        NotificationCenter.default.post(name: NSNotification.Name("premiumUpdate"), object: nil)
    }
    
    static func addObsorverToCurrentUser(observer: Any, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name("currentUser"), object: nil)
    }
    
    static func addObsorverToPremiumUpdate(observer: Any, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name("premiumUpdate"), object: nil)
    }
}
