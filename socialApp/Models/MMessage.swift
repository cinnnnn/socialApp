//
//  MRequestChat.swift
//  socialApp
//
//  Created by Денис Щиголев on 17.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

struct MMessage: Hashable, Codable {
    var content: String
    var senderUserName: String
    var senderID: String
    var id: String?
    var date: Date
    
    init(user: MPeople, content: String, id: String? = nil) {
        self.content = content
        senderUserName = user.userName
        senderID = user.id
        self.id = id
        date = Date()
    }
    
    enum CodingKeys: String, CodingKey {
        case content
        case senderUserName
        case senderID
        case id = "id"
        case date = "date"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(content)
    }
    
    static func == (lhs: MMessage, rhs: MMessage) -> Bool {
        return lhs.content == rhs.content
    }
    

}
