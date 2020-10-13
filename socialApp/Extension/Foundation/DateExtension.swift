//
//  DateExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 29.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

extension Date {
    
    func getFormattedDate(format: String, withTime: Bool? = nil) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        if let withTime = withTime {
            if !withTime {
                dateFormatter.timeStyle = .none
            }
        }
        
        return dateFormatter.string(from: self)
    }
    
    func getShortFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        return dateFormatter.string(from: self)
    }
}
