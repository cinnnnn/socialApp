//
//  Sex.swift
//  socialApp
//
//  Created by Денис Щиголев on 10.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum MGender: String, CaseIterable {
    case man = "Парень"
    case woman = "Девушка"
    case agender = "Agender"
    case androgyne = "Androgyne"
    case androgynous = "Androgynous"
    case bigender = "Bigender"
    case genderFluid = "Gender Fluid"
    case genderNonconforming = "Gender Non Conforming"
    case genderVariant = "Gender Variant"
    case genderqueer = "Genderqueer"
    case intersex = "Intersex"
    case mtf = "Male to Female"
    case neither = "Neither"
    case trans = "Trans"
    case transMan = "Trans Man"
    case transWoman = "Trans Woman"
    case transMale = "Trans Male"
    case transFemale = "Trans Female"
    case transPerson = "Trans Person"
    case nonBinary = "Non-Binary"
    case pagender = "Pagender"
    case twoSpirit = "Two-spirit"
    case other = "Другое"
}

extension MGender {
    static let description = "Гендер" 
    
    static var modelStringAllCases: [String] {
        allCases.map { gender -> String in
             gender.rawValue
        }
    }
}


