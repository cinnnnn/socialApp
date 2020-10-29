//
//  UserDefaultsError.swift
//  socialApp
//
//  Created by Денис Щиголев on 29.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum UserDefaultsError {
    case cantGetData
}

extension UserDefaultsError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .cantGetData:
            return NSLocalizedString("Невозможоно получить данные из User Defaults", comment: "")
        }
    }
}
