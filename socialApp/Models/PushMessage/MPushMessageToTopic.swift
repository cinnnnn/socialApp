//
//  MPushMessageToTopic.swift
//  socialApp
//
//  Created by Денис Щиголев on 12.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

struct MPushMessageToTopic: Codable {
    let topic: String
    let notification: MAps
    let data: [String: String]?
}




