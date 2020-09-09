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
    
    static func avenir(size: CGFloat) -> UIFont {
        guard let font = UIFont.init(name: "avenirBold", size: size) else { fatalError("Unknown Font")}
        return font
    }
}