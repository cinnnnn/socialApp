//
//  ChatError.swift
//  socialApp
//
//  Created by Денис Щиголев on 23.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum ChatError {
    case getUserData
}

extension ChatError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .getUserData:
            return NSLocalizedString("Ошибка получения данных чата", comment: "")
        }
    }
}
