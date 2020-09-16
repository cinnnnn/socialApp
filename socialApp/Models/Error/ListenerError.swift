//
//  ListenerError.swift
//  socialApp
//
//  Created by Денис Щиголев on 16.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum ListenerError {
    case snapshotNotExist
    case peopleCollectionNotExist
}

extension ListenerError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .snapshotNotExist:
            return NSLocalizedString("Snapshot слушателя не существует", comment: "")
        case .peopleCollectionNotExist:
            return NSLocalizedString("Коллекция текущих пользователей не существует", comment: "")
        }
    }
}
