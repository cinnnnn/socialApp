//
//  AuthError.swift
//  socialApp
//
//  Created by Денис Щиголев on 02.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum AuthError {
    case userError
    case notFilled
    case invalidEmail
    case invalidPassword
    case passwordNotMatch
    case unknowError
    case serverError
    case appleToken
    case serializeAppleToken
    case missingEmail
    case credentialError
}

extension AuthError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .userError:
            return NSLocalizedString("Ошибка получения данных пользователя", comment: "")
        case .notFilled:
            return NSLocalizedString("Заполни все поля", comment: "")
        case .invalidEmail:
            return NSLocalizedString("Некорректно введен Email", comment: "")
        case .invalidPassword:
            return NSLocalizedString("Некорректно введен пароль", comment: "")
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
        case .missingEmail:
            return NSLocalizedString("Отсутствует Email у пользователя", comment: "")
        case .credentialError:
            return NSLocalizedString("Не удалось получить данные авторизации", comment: "")
        }
    }
}
