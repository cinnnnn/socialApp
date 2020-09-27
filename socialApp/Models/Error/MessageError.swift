//
//  MessageError.swift
//  socialApp
//
//  Created by Денис Щиголев on 27.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum MessageError {
    case getMessageData
}

extension MessageError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .getMessageData:
            return NSLocalizedString("Ошибка получения данных сообщения", comment: "")
        }
    }
}
