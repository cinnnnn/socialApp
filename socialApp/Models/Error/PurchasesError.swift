//
//  PurchasesError.swift
//  socialApp
//
//  Created by Денис Щиголев on 04.12.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation


enum PurchasesError {
    case unknownProduct
}

extension PurchasesError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        
        case .unknownProduct:
           return NSLocalizedString("Неизвестный продукт", comment: "")
        }
    }
}
