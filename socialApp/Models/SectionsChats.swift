//
//  SectionsChats.swift
//  socialApp
//
//  Created by Денис Щиголев on 26.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum SectionsChats: Int, CaseIterable {
    case waitingChats
    case activeChats
    
    func description() -> String {
        switch self {
        case .waitingChats:
            return "Запросы"
        case .activeChats:
            return "Активные чаты"
        }
    }
}
