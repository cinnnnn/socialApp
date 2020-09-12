//
//  StorageError.swift
//  socialApp
//
//  Created by Денис Щиголев on 12.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum StorageError {
    case referenceError
    case getDataError
    case setDataError
    case getImageFromDataError
}

extension StorageError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
            
        case .referenceError:
            return NSLocalizedString("Ошибка референса на файл", comment: "")
        case .getDataError:
            return NSLocalizedString("Ошибка получения файла", comment: "")
        case .setDataError:
            return NSLocalizedString("Ошибка загрузки файла на сервер", comment: "")
        case .getImageFromDataError:
            return NSLocalizedString("Невозможно конвертировать данные с сервера в изображение", comment: "")
        }
    }
}
