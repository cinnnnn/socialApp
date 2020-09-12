//
//  AuthError.swift
//  socialApp
//
//  Created by Денис Щиголев on 02.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum AuthError {
    case notFilled
    case invalidEmail
    case passwordNotMatch
    case unknowError
    case serverError
    case appleToken
    case serializeAppleToken
}

extension AuthError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .notFilled:
            return NSLocalizedString("Заполни все поля", comment: "")
        case .invalidEmail:
            return NSLocalizedString("Некорректно введен Email", comment: "")
        case .passwordNotMatch:
            return NSLocalizedString("Пароли не совпадают", comment: "")
        case .unknowError:
            return NSLocalizedString("Неизвестная ошибка", comment: "")
        case .serverError:
            return NSLocalizedString("Ошибка сервера", comment: "")
        case .appleToken:
            return NSLocalizedString("Невозможно поолучить токен Apple", comment: "")
        case .serializeAppleToken:
            return NSLocalizedString("Невозможно выполнить сериализацию токена Apple", comment: "")
        }
    }
}
