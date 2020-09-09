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
                     multiline: Bool = false,
                     textFont: UIFont = .systemFont(ofSize: 12),
                     opacity: Float = 1) {
        self.init()
        font = textFont
        layer.opacity = opacity
        numberOfLines = multiline ? 0 : 1
        text = labelText

    }
    
    convenience init(labelText: String, textFont: UIFont?) {
        self.init()
        text = labelText
        font = textFont
    }
}
