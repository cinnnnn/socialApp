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
        return UIColor  { $0.userInterfaceStyle == .dark ? dark : light  }
    }
    
    
    static func myBackgroundColor() -> UIColor {
        dynamicColor(light: #colorLiteral(red: 0.8748111129, green: 0.8696112037, blue: 0.8788084388, alpha: 1), dark: #colorLiteral(red: 0.1263937652, green: 0.1256497502, blue: 0.1269704401, alpha: 1))
    }
    
    static func myGrayColor() -> UIColor {
        
        dynamicColor(light: #colorLiteral(red: 0.3098039216, green: 0.337254902, blue: 0.3725490196, alpha: 1), dark: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
    }
    
    static func myLightGrayColor() -> UIColor {
        
        dynamicColor(light: #colorLiteral(red: 0.9379875064, green: 0.9324114919, blue: 0.942273736, alpha: 1), dark: #colorLiteral(red: 0.2514118254, green: 0.2546254992, blue: 0.254514575, alpha: 1))
    }
    
    static func mySuperLightGrayColor() -> UIColor {
        
        dynamicColor(light: #colorLiteral(red: 0.9750242829, green: 0.9692278504, blue: 0.9794797301, alpha: 1), dark: #colorLiteral(red: 0.1639038324, green: 0.168120265, blue: 0.1680073738, alpha: 1))
    }
    
    static func myWhiteColor() -> UIColor {
        
        dynamicColor(light: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), dark: #colorLiteral(red: 0.1518749893, green: 0.1509793401, blue: 0.1525681615, alpha: 1))
    }
    
    static func myLabelColor() -> UIColor {
        
        dynamicColor(light: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), dark: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    }
    
    static func myMessageColor() -> UIColor {
        
        dynamicColor(light: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), dark: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    }
    
    static func friendMessageColor() -> UIColor {
        dynamicColor(light: #colorLiteral(red: 0.9490961432, green: 0.9434540272, blue: 0.9534330964, alpha: 1), dark: #colorLiteral(red: 0.08094476908, green: 0.08047137409, blue: 0.08131367713, alpha: 1))
    }
    
    static func adminMessageColor() -> UIColor {
        dynamicColor(light: #colorLiteral(red: 0.431372549, green: 0.7764705882, blue: 0.7921568627, alpha: 1), dark: #colorLiteral(red: 0.431372549, green: 0.7764705882, blue: 0.7921568627, alpha: 1))
    }
    
    static func myFirstButtonColor() -> UIColor {
        dynamicColor(light: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), dark: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    }
    
    static func mySecondButtonColor() -> UIColor {
        dynamicColor(light: #colorLiteral(red: 0.9379875064, green: 0.9324114919, blue: 0.942273736, alpha: 1), dark: #colorLiteral(red: 0.2514118254, green: 0.2546254992, blue: 0.254514575, alpha: 1))
    }
    
    static func myFirstButtonLabelColor() -> UIColor {
        dynamicColor(light: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), dark: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
    }
    
    static func mySecondButtonLabelColor() -> UIColor {
        dynamicColor(light: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), dark: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    }
    
    static func myFirstColor() -> UIColor {
        dynamicColor(light: #colorLiteral(red: 0.8, green: 0.6705882353, blue: 0.8470588235, alpha: 1), dark: #colorLiteral(red: 0.8, green: 0.6705882353, blue: 0.8470588235, alpha: 1))
    }
    
    static func myFirstSatColor() -> UIColor {
        dynamicColor(light: #colorLiteral(red: 0.5176470588, green: 0.4549019608, blue: 0.631372549, alpha: 1), dark: #colorLiteral(red: 0.5176470588, green: 0.4549019608, blue: 0.631372549, alpha: 1))
    }
    
    static func mySecondColor() -> UIColor {
        dynamicColor(light: #colorLiteral(red: 0.431372549, green: 0.7764705882, blue: 0.7921568627, alpha: 1), dark: #colorLiteral(red: 0.431372549, green: 0.7764705882, blue: 0.7921568627, alpha: 1))
    }
    
    static func mySecondSatColor() -> UIColor {
        dynamicColor(light: #colorLiteral(red: 0.03137254902, green: 0.5921568627, blue: 0.6156862745, alpha: 1), dark: #colorLiteral(red: 0.03137254902, green: 0.5921568627, blue: 0.6156862745, alpha: 1))
    }
    
    
    static func myPurpleColor() -> UIColor {
        
        dynamicColor(light: #colorLiteral(red: 0.5764705882, green: 0.5960784314, blue: 0.9921568627, alpha: 1), dark: #colorLiteral(red: 0.6526986957, green: 0.6832183003, blue: 1, alpha: 1))
    }
    
    static func myPinkColor() -> UIColor {
         dynamicColor(light:  #colorLiteral(red: 0.9411764706, green: 0.4862745098, blue: 0.9019607843, alpha: 1), dark:  #colorLiteral(red: 0.9787521958, green: 0.7720793486, blue: 0.9878835082, alpha: 1))
    }
}
