//
//  UIButtonExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 28.06.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    convenience init(newBackgroundColor: UIColor,
                     newBorderColor: UIColor,
                     title: String,
                     titleColor: UIColor,
                     font: UIFont? = .boldSystemFont(ofSize: 18),
                     cornerRadius: CGFloat = 4,
                     isShadow: Bool = false) {
        self.init(type: .system)
        
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        backgroundColor = newBackgroundColor
        titleLabel?.font = font
        
        layer.borderColor = newBorderColor.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = cornerRadius
        
        if isShadow {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowRadius = 4
            layer.shadowOpacity = 0.4
            layer.shadowOffset = CGSize(width: 0, height: 4)
        }
    }
    
    convenience init(image: UIImage) {
        self.init()
        setImage(image, for: .normal)
    }
    
}
