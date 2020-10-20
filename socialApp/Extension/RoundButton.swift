//
//  RoundButton.swift
//  socialApp
//
//  Created by Денис Щиголев on 20.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class RoundButton: UIButton {
    
    convenience init(newBackgroundColor: UIColor,
                     title: String,
                     titleColor: UIColor,
                     font: UIFont? = .avenirBold(size: 16),
                     isEnable: Bool = true,
                     isHidden: Bool = false,
                     opacity: Float = 1) {
        self.init()
        
        isEnabled = isEnable
        self.isHidden = isHidden
        
        setTitle(title, for: .normal)
        setTitle(title, for: .selected)
        setTitleColor(titleColor, for: .normal)
        setTitleColor(.label, for: .disabled)
        backgroundColor = newBackgroundColor
        titleLabel?.font = font
        
        layer.opacity = opacity
       
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
}
