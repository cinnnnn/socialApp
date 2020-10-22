//
//  MReports.swift
//  socialApp
//
//  Created by Денис Щиголев on 14.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum MReports: String, Codable {
    case fake = "Фейк"
    case spam = "Спам"
    case offensive = "Агрессивный"
    case underage = "Несовершеннолетний"
    case oter = "Другое"
}
