//
//  UITextViewExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 29.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

extension UITextView {
    
    convenience init(text: String, isEditableText: Bool, delegate: UITextViewDelegate?) {
        self.init()
        
        self.text = text
        isEditable = isEditableText
        isSelectable = isEditableText
        isScrollEnabled = false //for autosize height
        backgroundColor = nil
        font = .systemFont(ofSize: 18, weight: .regular)
        textColor = .label
        
        //for setup maximum lines and symbols
        if isEditableText {
            textContainer.maximumNumberOfLines = 3
            textContainer.lineBreakMode = .byClipping
            self.delegate = delegate
        }
    }
}
