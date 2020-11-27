//
//  MDefaultsDesires.swift
//  socialApp
//
//  Created by Денис Щиголев on 27.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum MDefaultsDesires: String, CaseIterable {
    case fwb = "FWB"
    case friendships = "Дружба"
    case freeRelationship = "Свобдные отношения"
    case seriousRelationship = "Серьезные отношения"
    case communication = "Общение"
    case sexting = "Секстинг"
    case dates = "Встречи"
    case travels = "Совместные путешествия"
    case party = "Тусовки"
    
}

extension MDefaultsDesires {
    static func getSortedDesires() -> [String] {
        allCases.map { interest -> String in
            interest.rawValue
        }.sorted{ $0 > $1 }
    }
}
