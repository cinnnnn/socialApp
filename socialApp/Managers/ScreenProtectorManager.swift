//
//  ScreenProtectorManager.swift
//  socialApp
//
//  Created by Денис Щиголев on 12.12.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class ScreenProtectorManager {
    
    static let shared = ScreenProtectorManager()
    private var window: UIWindow?

    private init() { }
    
    func showScreenProtector(viewController: UIViewController) {
    
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.windowLevel = .alert + 1
        window?.windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        window?.rootViewController = viewController
        window?.isHidden = false
    }
    
    func hideScreenProtector() {
        window?.isHidden = true
        window = nil
    }
}
