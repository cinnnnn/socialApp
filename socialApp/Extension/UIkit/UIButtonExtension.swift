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
    
    convenience init(newBackgroundColor: UIColor?,
                     newBorderColor: UIColor = .label,
                     borderWidth: CGFloat = 0,
                     title: String,
                     titleColor: UIColor,
                     font: UIFont? = .avenirBold(size: 16),
                     cornerRadius: CGFloat = MDefaultLayer.smallCornerRadius.rawValue,
                     isShadow: Bool = false,
                     isEnable: Bool = true,
                     isHidden: Bool = false,
                     opacity: Float = 1) {
        self.init(type: .system)
        
        isEnabled = isEnable
        self.isHidden = isHidden
        
        setTitle(title, for: .normal)
        setTitle(title, for: .selected)
        setTitleColor(titleColor, for: .normal)
        setTitleColor(.label, for: .disabled)
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
    
    convenience init(image: UIImage?, isBackGroundImage: Bool = false, tintColor: UIColor, backgroundColor: UIColor, cornerRadius: CGFloat = 0) {
        self.init()
        if isBackGroundImage {
            setBackgroundImage(image, for: .normal)
        } else {
            setImage(image, for: .normal)
        }
        imageView?.tintColor = tintColor
        imageView?.backgroundColor = backgroundColor
        self.backgroundColor = backgroundColor
        clipsToBounds = true
     
    }
}
