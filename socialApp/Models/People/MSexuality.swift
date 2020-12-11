//
//  MSexuality.swift
//  socialApp
//
//  Created by Денис Щиголев on 11.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum MSexuality: String, CaseIterable {
    case straight = "Гетеро"
    case bisexual = "Бисексуал"
    case pansexual = "Пансексуал"
    case polisexual = "Полисексуал"
    case autoSexual = "Автосексуал"
    case androgynosexual = "Андрогиносексуал"
    case androsexual = "Андросексуал"
    case asexual = "Асексуал"
    case demisexual = "Демисексуал"
    case homoflexible = "Гомо-флекс"
    case heteroflexible = "Гетеро-флекс"
    case gynosexual = "Гиносексуал"
    case greysexual = "Грейсексуал"
    case litosexual = "Литосексуал"
    case objectumsexual = "Объектумсексуал"
    case omnisexual = "Омнисексуал"
    case scoliosexual = "Сколиосексуал"
    case other = "Другое"
}

extension MSexuality {
    static let description = "Ориентация"
    
    static var modelStringAllCases: [String] {
        allCases.map { gender -> String in
             gender.rawValue
        }
    }
}
