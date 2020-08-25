//
//  UIColorExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 05.07.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit



extension UIColor {
    
    static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        guard #available(iOS 13.0, *) else { return light }
        return UIColor  { $0.userInterfaceStyle == .dark ? dark : light }
    }
    
    
    static func myBackgroundColor() -> UIColor {
        
        dynamicColor(light: #colorLiteral(red: 0.8525181413, green: 0.8722963929, blue: 0.8775926232, alpha: 1), dark: #colorLiteral(red: 0.1263937652, green: 0.1256497502, blue: 0.1269704401, alpha: 1))
    }
    
    static func myHeaderColor() -> UIColor {
        
        dynamicColor(light: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), dark: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
    }
}
