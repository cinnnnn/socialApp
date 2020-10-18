//
//  ListenerError.swift
//  socialApp
//
//  Created by Денис Щиголев on 16.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum FirestoreError {
    case snapshotNotExist
    case peopleCollectionNotExist
    case chatsCollectionNotExist
    case cantDeleteElementInCollection
}

extension FirestoreError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .snapshotNotExist:
            return NSLocalizedString("Snapshot не существует", comment: "")
        case .peopleCollectionNotExist:
            return NSLocalizedString("Коллекция текущих пользователей не существует", comment: "")
        case .chatsCollectionNotExist:
            return NSLocalizedString("Коллекция ожидающих чатов не существует", comment: "")
        case .cantDeleteElementInCollection:
            return NSLocalizedString("Невозможно удалить элемент коллекции", comment: "")
        }
    }
}
