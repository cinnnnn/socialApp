//
//  MReports.swift
//  socialApp
//
//  Created by Денис Щиголев on 14.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum MTypeReports: String, Codable, CaseIterable{
    case fake = "Фейк"
    case spam = "Спам"
    case offensiveContent = "Оскорбительный контент"
    case underage = "Несовершеннолетний"
    case other = "Другое"
    
    static let description = "Жалоба"
    static let getReport = "Получил жалобу"
    
    static var modelStringAllCases: [String] {
        allCases.map { report -> String in
            report.rawValue
        }
    }
}
