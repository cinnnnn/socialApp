//
//  UITextViewExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 29.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

extension UITextView {
    
    convenience init(text: String = "",
                     isEditable: Bool = true) {
        self.init()
        
        self.text = text
        self.isEditable = isEditable
        isSelectable = isEditable
        isScrollEnabled = false //for autosize height
        backgroundColor = nil
        font = .avenirRegular(size: 16)
        textColor = .lightGray
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.borderColor = UIColor.label.cgColor
        layer.borderWidth = 0
        layer.cornerRadius = 4
        
        //for setup maximum lines and symbols
        if isEditable {
            textContainer.maximumNumberOfLines = 100
            textContainer.lineBreakMode = .byClipping
        }
    }
}

//MARK: doneButton
extension UITextView {
    
    func addDoneButton(onDone: (target: Any, action:(Selector))? = nil) {
        
        let onDone = onDone ?? (target: self, action: #selector(defaultDoneAction))
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.barTintColor = .myWhiteColor()
        toolBar.backgroundColor = .myWhiteColor()
        toolBar.tintColor = .label
        toolBar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Готово", style: .done, target: self, action: onDone.action)
        ]
        toolBar.sizeToFit()
        
        self.inputAccessoryView = toolBar
    }
    
    @objc func defaultDoneAction() {
        self.resignFirstResponder()
    }
}
