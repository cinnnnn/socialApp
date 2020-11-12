//
//  Maps.swift
//  socialApp
//
//  Created by Денис Щиголев on 12.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

struct MAps: Codable {
    let title: String
    let body: String
    let category: String
    let badge: Int
    let sound: String
    let mutableContent: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case body
        case category = "click_action"
        case badge
        case sound
        case mutableContent = "mutable_content"
    }
}
