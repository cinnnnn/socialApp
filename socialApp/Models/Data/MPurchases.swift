//
//  MPurchases.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum MPurchases: String, Codable {
    case sevenDays = "Flava_premium_7_days"
    case oneMonth = "Flava_premium_30_day"
    case threeMonth = "Flava_premium_90_days"
    case oneYear = "Flava_premium_1_year"
}
