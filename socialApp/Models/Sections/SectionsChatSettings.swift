//
//  SectionsChatSettings.swift
//  socialApp
//
//  Created by Денис Щиголев on 04.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum SectionsChatSettings: Int, CaseIterable, UniversalSection {
    case chatSettings
    
    func description() -> String {
        switch self {
        case .chatSettings:
            return "Настройки чата"
        }
    }
}
