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
        dynamicColor(light: #colorLiteral(red: 0.8748111129, green: 0.8696112037, blue: 0.8788084388, alpha: 1), dark: #colorLiteral(red: 0.1263937652, green: 0.1256497502, blue: 0.1269704401, alpha: 1))
    }
    
    static func myGrayColor() -> UIColor {
        
        dynamicColor(light: #colorLiteral(red: 0.310331881, green: 0.3371494412, blue: 0.3730729818, alpha: 1), dark: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
    }
    
    static func myLightGrayColor() -> UIColor {
        
        dynamicColor(light: #colorLiteral(red: 0.8850732446, green: 0.8891695142, blue: 0.8991813064, alpha: 1), dark: #colorLiteral(red: 0.1024033502, green: 0.1037172154, blue: 0.103666164, alpha: 1))
    }
    
    static func myWhiteColor() -> UIColor {
        
        dynamicColor(light: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), dark: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
    }
    
    static func myLabelColor() -> UIColor {
        
        dynamicColor(light: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), dark: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    }
    
    static func myMessageColor() -> UIColor {
        
        dynamicColor(light: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), dark: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
    }
    
    static func friendMessageColor() -> UIColor {
        dynamicColor(light: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), dark: #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
    }
    
    static func myPurpleColor() -> UIColor {
        
        dynamicColor(light: #colorLiteral(red: 0.5750052333, green: 0.5949758887, blue: 0.9911155105, alpha: 1), dark: #colorLiteral(red: 0.6526986957, green: 0.6832183003, blue: 1, alpha: 1))
    }
    
    static func myPinkColor() -> UIColor {
         dynamicColor(light:  #colorLiteral(red: 0.9419099689, green: 0.4851585627, blue: 0.9007419348, alpha: 1), dark:  #colorLiteral(red: 0.9787521958, green: 0.7720793486, blue: 0.9878835082, alpha: 1))
    }
}
