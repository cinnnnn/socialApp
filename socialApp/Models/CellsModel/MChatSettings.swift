//
//  MChatSettings.swift
//  socialApp
//
//  Created by Денис Щиголев on 04.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

enum MChatSettings: Int, UniversalCollectionCellModel, CaseIterable {

    case disableTimer
    case unmatch
    case reportUser
    
    func image() -> UIImage?  {
        switch self {
        
        case .disableTimer:
            return UIImage(systemName: "person") ?? #imageLiteral(resourceName: "disclouser")
        case .unmatch:
            return UIImage(systemName: "person") ?? #imageLiteral(resourceName: "disclouser")
        case .reportUser:
            return UIImage(systemName: "magnifyingglass") ?? #imageLiteral(resourceName: "disclouser")
        }
    }
    
    func description() -> String  {
        switch self {
        
        case .disableTimer:
            return "Отключить таймер чата"
        case .unmatch:
            return "Разорвать пару"
        case .reportUser:
            return "Пожаловаться на пользователя"
        }
    }
    func typeOfCell() -> MCellType {
        switch self {
        case .disableTimer:
            return .switchCell
        case .unmatch:
            return .buttonCell
        case .reportUser:
            return .buttonCell
        }
    }
}
