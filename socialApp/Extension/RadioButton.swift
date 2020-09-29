//
//  RadioButton.swift
//  socialApp
//
//  Created by Денис Щиголев on 15.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class RadioButton: NSObject {
    
    var buttonsArray: [UIButton] = [] {
        didSet {
            for button in buttonsArray {
                let newTitleSelectedColor = button.titleColor(for: .normal)
                
                button.setImage(UIImage(named: "radio"), for: .normal)
                button.setImage(UIImage(named: "radio_filled"), for: .selected)
                button.setTitleColor(newTitleSelectedColor, for: .selected)
                button.tintColor = .systemBackground
            }
        }
    }
    
    var selectedButton: UIButton?
    var defaultButton: UIButton = UIButton()  {
        didSet {
            buttonArrayUpdated(buttonSelected: self.defaultButton)
        }
    }
       
    func buttonArrayUpdated(buttonSelected: UIButton) {
        for button in buttonsArray {
            if button == buttonSelected {
                selectedButton = button
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
    }
}
