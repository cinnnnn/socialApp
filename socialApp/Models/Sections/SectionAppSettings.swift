//
//  SectionAppSettings.swift
//  socialApp
//
//  Created by Денис Щиголев on 27.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum SectionAppSettings: Int, CaseIterable {
    case appSettings
    
    func description() -> String {
        switch self {
        case .appSettings:
            return "Настройки приложения"
        }
    }
}
