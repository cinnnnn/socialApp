//
//  UIApplicationExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 30.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

extension UIApplication {
    static var statusBarHeight: CGFloat {
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            let window = shared.windows.filter { $0.isKeyWindow }.first
            statusBarHeight = window?.safeAreaInsets.top ?? window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = shared.statusBarFrame.height
        }
        return statusBarHeight
    }
    
    static func getCurrentViewController() -> UIViewController? {

        if let rootController = shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController {
           var currentController: UIViewController! = rootController
           while( currentController.presentedViewController != nil ) {
               currentController = currentController.presentedViewController
           }
           return currentController
       }
       return nil

   }
}
