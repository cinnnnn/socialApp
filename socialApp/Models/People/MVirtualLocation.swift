//
//  MVirtualLocation.swift
//  socialApp
//
//  Created by Денис Щиголев on 22.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum MVirtualLocation: Int, CaseIterable {
    case current
    case forPlay
    
    func description() -> String {
        switch self {
        case .current:
            return "Текущая локация"
        case .forPlay:
            return "Комната развлечений"
        }
    }
    
    static func index(location: String) -> Int {
        switch location {
        case "Текущая локация":
            return 0
        case "Комната развлечений":
            return 1
        default:
            return 0
        }
    }
    
    var defaultValue: [String : Double] {
        switch self {
        
        case .current:
            return  [MLocation.longitude.rawValue: MLocation.longitude.defaultValue,
                     MLocation.latitude.rawValue: MLocation.latitude.defaultValue]
        case .forPlay:
            return [MLocation.longitude.rawValue: 37.559796, MLocation.latitude.rawValue: 55.730898]
        }
    }
}

extension MVirtualLocation {
    static let description = "Локация"
    
    static var modelStringAllCases: [String] {
        allCases.map { gender -> String in
             gender.description()
        }
    }
}
