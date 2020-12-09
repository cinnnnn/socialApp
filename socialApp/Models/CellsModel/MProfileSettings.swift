//
//  MSettings.swift
//  socialApp
//
//  Created by Денис Щиголев on 07.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit


enum MProfileSettings: Int, CollectionCellModel {
    case profileInfo
    case premiumButton
    case setupProfile
    case setupSearch
    case appSettings
    case contacts
    case aboutInformation
    case adminPanel
    
    
    func description() -> String  {
        switch self {
        
        case .profileInfo:
            return "Профиль"
        case .premiumButton:
            return "Flava premium"
        case .setupProfile:
            return "Редактировать профиль"
        case .setupSearch:
            return "Параметры поиска"
        case .appSettings:
            return "Настройки"
        case .contacts:
            return "Контакты"
        case .aboutInformation:
            return "Информация"
        case .adminPanel:
            return "Панель администратора"
        }
    }
}

extension MProfileSettings: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}
