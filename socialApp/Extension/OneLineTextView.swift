//
//  OneLineTextView.swift
//  socialApp
//
//  Created by Денис Щиголев on 10.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class OneLineTextView: UITextView {
    
    convenience init(text: String = "",
                     isEditable: Bool = true) {
        self.init()
        
        self.text = text
        self.isEditable = isEditable
        isSelectable = isEditable
        isScrollEnabled = false //for autosize height
        backgroundColor = nil
        font = .systemFont(ofSize: 16, weight: .regular)
        textColor = .lightGray
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.borderColor = UIColor.label.cgColor
        layer.borderWidth = 0
        layer.cornerRadius = 4
        
        //for setup maximum lines and symbols
        if isEditable {
            textContainer.maximumNumberOfLines = 5
            textContainer.lineBreakMode = .byClipping
        }
    }
}
