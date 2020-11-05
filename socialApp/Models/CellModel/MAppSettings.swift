//
//  MAppSettings.swift
//  socialApp
//
//  Created by Денис Щиголев on 27.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//


import UIKit


enum MAppSettings: Int, CaseIterable, CollectionCellModel {
    case about
    case logOut
    case terminateAccaunt
    
    func image() -> UIImage  {
        switch self {
        
        case .about:
            return UIImage(systemName: "person") ?? #imageLiteral(resourceName: "disclouser")
        case .logOut:
            return UIImage(systemName: "person") ?? #imageLiteral(resourceName: "disclouser")
        case .terminateAccaunt:
            return UIImage(systemName: "magnifyingglass") ?? #imageLiteral(resourceName: "disclouser")
        }
    }
    
    func description() -> String  {
        switch self {
        
        case .about:
            return "Информация"
        case .logOut:
            return "Выйти"
        case .terminateAccaunt:
            return "Удалить аккаунт"
        }
    }
    
    func cellType() -> MCellType {
        switch self {
        case .about:
            return .buttonCell
        case .logOut:
            return .buttonCell
        case .terminateAccaunt:
            return .buttonCell
        }
    }
}

extension MAppSettings: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}
