//
//  UIFontExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 28.06.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    static func avenirBold(size: CGFloat) -> UIFont {
        guard let font = UIFont.init(name: "AvenirNext-Bold", size: size) else { fatalError("Unknown Font")}

        return font
    }
    
    static func avenirRegular(size: CGFloat) -> UIFont {
        guard let font = UIFont.init(name: "AvenirNext-Regular", size: size) else { fatalError("Unknown Font")}

        return font
    }
    
    static func avenirUltraLight(size: CGFloat) -> UIFont {
        guard let font = UIFont.init(name: "AvenirNext-UltraLight", size: size) else { fatalError("Unknown Font")}

        return font
    }
    
    static func avenirHeavy(size: CGFloat) -> UIFont {
        guard let font = UIFont.init(name: "AvenirNext-Heavy", size: size) else { fatalError("Unknown Font")}

        return font
    }
}
