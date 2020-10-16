//
//  SectionsChats.swift
//  socialApp
//
//  Created by Денис Щиголев on 26.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation


enum SectionsChats: Int, CaseIterable {
    case newChats
    case activeChats
    
    func description(count: Int) -> String {
        switch self {
        case .newChats:
            return "Новых чатов \(count) "
        case .activeChats:
            return "Активных чатов \(count)"
        }
    }
}
