//
//  OneLineTextField.swift
//  socialApp
//
//  Created by Денис Щиголев on 02.07.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class OneLineTextField: UITextField {
    
    private var datePicker:UIDatePicker?
    var backspacePressed: (()-> Void)?
    convenience init(isSecureText: Bool,
                     tag: Int,
                     opacity:Float = 1,
                     isEnable: Bool = true,
                     withButton: Bool = false,
                     buttonText: String = "",
                     placeHoledText: String = "",
                     datePicker: Bool = false) {
        self.init()
        
        self.tag = tag
        isEnabled = isEnable
        font = .avenirRegular(size: 16)
        layer.opacity = opacity
        borderStyle = .none
        translatesAutoresizingMaskIntoConstraints = false
        isSecureTextEntry = isSecureText
        placeholder = placeHoledText
          
        let bottomView =  UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        bottomView.backgroundColor = .myLightGrayColor()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(bottomView)
        
        NSLayoutConstraint.activate([
            bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 1),
            bottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        if withButton {
            let textFieldButton = UIButton()
            textFieldButton.setTitle(buttonText, for: .normal)
            textFieldButton.setTitleColor(.label, for: .normal)

            rightView = textFieldButton
            rightViewMode = .always
            rightView?.frame = CGRect(x: 0, y: 0, width: 8 , height: 8)
        }
        
        if datePicker {
            self.datePicker = UIDatePicker()
            guard let picker = self.datePicker else { return }
            picker.datePickerMode = .date
            if #available(iOS 13.4, *) {
                picker.preferredDatePickerStyle = .wheels
            }
            if let date = text?.getFormattedDate(format: "MM/dd/yyyy", withTime: false) {
                picker.date = date
            } else {
                picker.date = Date()
            }
            
            let toolBar = UIToolbar()
            toolBar.barStyle = .default
            toolBar.barTintColor = .myWhiteColor()
            toolBar.backgroundColor = .myWhiteColor()
            toolBar.tintColor = .label
            toolBar.items = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
                UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(tapDoneDatePickerButton))
            ]
            toolBar.sizeToFit()
            
            inputAccessoryView = toolBar
            
            inputView = picker
        }
    }
}

extension OneLineTextField {
    override func deleteBackward() {
        super.deleteBackward()
        backspacePressed?()
    }
    
    func addToolBar(target: Any?, doneSelector: Selector?){
        
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.barTintColor = .myWhiteColor()
        toolBar.backgroundColor = .myWhiteColor()
        toolBar.tintColor = .label
        toolBar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Готово", style: .done, target: target ?? self, action: doneSelector ?? #selector(tapDoneButton))
        ]
        toolBar.sizeToFit()
        
        inputAccessoryView = toolBar
    }
}

extension OneLineTextField {
    
    @objc private func tapDoneDatePickerButton() {
            text = datePicker?.date.getShortFormattedDate()
            resignFirstResponder()
    }
    
    @objc private func tapDoneButton() {
            resignFirstResponder()
    }
}




