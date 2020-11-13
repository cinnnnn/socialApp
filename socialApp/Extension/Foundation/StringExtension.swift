//
//  StringExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

extension String {
    
    func getFormattedDate(format: String, withTime: Bool? = nil) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        if let withTime = withTime {
            if !withTime {
                dateFormatter.timeStyle = .none
            }
        }
        
        return dateFormatter.date(from: self)
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: Int) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        if let result = formatter.string(from: value as NSNumber) {
            appendLiteral(result)
        }
    }
    
    mutating func appendInterpolation(price: Double) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency

        if let result = formatter.string(from: price as NSNumber) {
            appendLiteral(result)
        }
    }
}
