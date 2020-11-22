//
//  SectionsProfile.swift
//  socialApp
//
//  Created by Денис Щиголев on 07.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum SectionsProfile: Int, CaseIterable {
    case profile
    case premium
    case settings
    
    func description() -> String {
        switch self {
        case .profile:
            return "Профиль"
        case .premium:
            return "Flava premium"
        case .settings:
            return "Настройки"
        }
    }
}
