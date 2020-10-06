//
//  MLocation.swift
//  socialApp
//
//  Created by Денис Щиголев on 06.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum MLocation: String {
    case longitude
    case latitude
    
    var defaultValue: Double {
        switch self {
    
        case .longitude:
           return 37.559796
        case .latitude:
           return 55.730898
        }
    }
}
