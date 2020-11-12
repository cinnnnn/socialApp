//
//  MPushMessage.swift
//  socialApp
//
//  Created by Денис Щиголев on 11.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

struct MPushMessage: Codable {
    let to: String
    let notification: MAps
    let data: [String: String]?
}


