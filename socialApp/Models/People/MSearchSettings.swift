//
//  MSearchSettings.swift
//  socialApp
//
//  Created by Денис Щиголев on 22.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum MSearchSettings: String {
    case distance
    case minRange
    case maxRange
    case currentLocation
    case onlyActive
    
    var defaultValue: Int {
        switch self {
    
        case .distance:
           //max distance - half of equator line
           return 20000
        case .minRange:
            return 18
        case .maxRange:
            return 70
        case .currentLocation:
            return 0
        case .onlyActive:
            return 0
        }
    }
}
