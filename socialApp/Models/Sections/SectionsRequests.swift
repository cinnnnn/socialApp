//
//  SectionsRequests.swift
//  socialApp
//
//  Created by Денис Щиголев on 17.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

import Foundation


enum SectionsRequests: Int, CaseIterable {
    case requestChats
    
    func description(count: Int) -> String {
        switch self {
        case .requestChats:
            return "Тебя лайкнули \(count) "
        }
    }
}
