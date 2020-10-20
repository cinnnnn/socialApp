//
//  LabelExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 28.06.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

extension UILabel {
    
    convenience init(labelText: String,
                     textFont: UIFont = .avenirRegular(size: 12),
                     textColor: UIColor = .myLabelColor(),
                     opacity: Float = 1,
                     aligment: NSTextAlignment = .left,
                     linesCount: Int = 1) {
        self.init()
        self.textColor = textColor
        font = textFont
        layer.opacity = opacity
        numberOfLines = linesCount
        text = labelText
        textAlignment = aligment
        

    }
    
    convenience init(labelText: String, textFont: UIFont?) {
        self.init()
        text = labelText
        font = textFont
    }
}
