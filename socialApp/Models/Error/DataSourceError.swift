//
//  DataSourceError.swift
//  socialApp
//
//  Created by Денис Щиголев on 24.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum DataSourceError {
    case unknownChatIdentificator
}

extension DataSourceError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        
        case .unknownChatIdentificator:
           return NSLocalizedString("Индификатор элемента отсутствует в dataSource", comment: "")
        }
    }
}
