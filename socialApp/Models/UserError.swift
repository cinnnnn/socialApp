//
//  UserError.swift
//  socialApp
//
//  Created by Денис Щиголев on 07.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum UserError {
    case notFilled
    case getUserData
    case incorrectSetProfile
}

extension UserError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .notFilled:
            return NSLocalizedString("Заполни все поля", comment: "")
        case .getUserData:
            return NSLocalizedString("Ошибка получения данных пользователя", comment: "")
        case .incorrectSetProfile:
            return NSLocalizedString("Профиль не заполнен, продложим регистрацию", comment: "")
        }
    }
}
