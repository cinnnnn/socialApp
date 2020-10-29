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
        self.datePickerMode = datePickerMode
        backgroundColor = .myWhiteColor()
        tintColor = .myLabelColor()
        locale = Locale.getPreferredLocale()
        let minYear = MSearchSettings.minRange.defaultValue
        let maxYear = MSearchSettings.maxRange.defaultValue
        minimumDate = Calendar.current.date(byAdding: .year, value: -maxYear, to: Date())
        maximumDate = Calendar.current.date(byAdding: .year, value: -minYear, to: Date())
    }
}
