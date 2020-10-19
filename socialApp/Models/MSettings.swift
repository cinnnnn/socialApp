//
//  MSettings.swift
//  socialApp
//
//  Created by Денис Щиголев on 07.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit


enum MSettings: Int {
    case profileInfo
    case setupProfile
    case setupSearch
    case adminPanel
    case about
    
    
    func image() -> UIImage  {
        switch self {
        
        case .profileInfo:
            return UIImage(systemName: "person") ?? #imageLiteral(resourceName: "disclouser")
        case .setupProfile:
           return #imageLiteral(resourceName: "people")
        case .setupSearch:
           return #imageLiteral(resourceName: "search")
        case .adminPanel:
            return #imageLiteral(resourceName: "slider")
        case .about:
           return #imageLiteral(resourceName: "info")
        
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
        case .adminPanel:
            return "Панель администратора"
        case .about:
           return "Информация"
        }
    }
}

extension MSettings: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}
