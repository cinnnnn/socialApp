//
//  MSexuality.swift
//  socialApp
//
//  Created by Денис Щиголев on 11.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum MSexuality: String, CaseIterable {
    case straight = "Straight"
    case gay = "Gay"
    case lesbian = "Lesbian"
    case bisexual = "Bisexual"
    case pansexual = "Pansexual"
    case polisexual = "Polisexual"
    case autoSexual = "Autosexual"
    case androgynosexual = "Androgynosexual"
    case androsexual = "Androsexual"
    case asexual = "Asexual"
    case demisexual = "Demisexual"
    case homoflexible = "Homoflexible"
    case gynosexual = "Gynosexual"
    case greysexual = "Greysexual"
    case litosexual = "Litosexual"
    case objectumsexual = "Objectumsexual"
    case omnisexual = "Omnisexual"
    case scoliosexual = "Scoliosexual"
}

extension MSexuality {
    static let description = "Сексуальность"
    
    static var modelStringAllCases: [String] {
        allCases.map { gender -> String in
             gender.rawValue
        }
    }
}
