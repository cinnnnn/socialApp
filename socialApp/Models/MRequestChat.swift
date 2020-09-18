//
//  MRequestChat.swift
//  socialApp
//
//  Created by Денис Щиголев on 17.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

struct MRequestChat: Hashable, Codable {
    var friendUserName: String
    var friendUserImageString: String
    var lastMessage: String
    var friendId: String
    var date: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(friendId)
    }
    
    static func == (lhs: MRequestChat, rhs: MRequestChat) -> Bool {
        return lhs.friendId == rhs.friendId
    }
    

}
