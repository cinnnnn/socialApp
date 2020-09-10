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
                     newBorderColor: UIColor = .label,
                     borderWidth: CGFloat = 1,
                     title: String,
                     titleColor: UIColor,
                     font: UIFont? = .boldSystemFont(ofSize: 18),
                     cornerRadius: CGFloat = 4,
                     isShadow: Bool = false,
                     isEnable: Bool = true,
                     isHidden: Bool = false,
                     opacity: Float = 1) {
        self.init(type: .system)
        
        isEnabled = isEnable
        self.isHidden = isHidden
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        backgroundColor = newBackgroundColor
        titleLabel?.font = font
        
        layer.opacity = opacity
        layer.borderColor = newBorderColor.cgColor
        layer.borderWidth = borderWidth
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
