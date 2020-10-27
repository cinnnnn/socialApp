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
    case setupProfile
    case setupSearch
    case appSettings
    case adminPanel
    
    
    func image() -> UIImage  {
        switch self {
        
        case .profileInfo:
            return UIImage(systemName: "person") ?? #imageLiteral(resourceName: "disclouser")
        case .setupProfile:
            return UIImage(systemName: "person") ?? #imageLiteral(resourceName: "disclouser")
        case .setupSearch:
            return UIImage(systemName: "magnifyingglass") ?? #imageLiteral(resourceName: "disclouser")
        case .appSettings:
            return UIImage(systemName: "slider.horizontal.3") ?? #imageLiteral(resourceName: "disclouser")
        case .adminPanel:
            return UIImage(systemName: "tv.circle") ?? #imageLiteral(resourceName: "disclouser")
        }
    }
    
    func description() -> String  {
        switch self {
        
        case .profileInfo:
            return "Профиль"
        case .setupProfile:
            return "Редактировать профиль"
        case .setupSearch:
            return "Параметры поиска"
        case .appSettings:
            return "Настройки"
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
