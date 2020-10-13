//
//  UIDatePickerExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

extension UIDatePicker {
    
    convenience init(datePickerMode: UIDatePicker.Mode ) {
        self.init()
        self.datePickerMode = .date
        backgroundColor = .myWhiteColor()
        tintColor = .myLabelColor()
        locale = Locale.getPreferredLocale()
    }
}
