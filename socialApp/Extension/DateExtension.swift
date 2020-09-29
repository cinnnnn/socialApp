//
//  DateExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 29.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

extension Date {
    
    func getFormattedDate(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
