//
//  MChat.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct MChat: Hashable, Codable {
    var friendUserName: String
    var friendUserImageString: String
    var lastMessage: String
    var friendId: String
    var date: Date
    
    init(friendUserName: String,
         friendUserImageString: String,
         lastMessage: String,
         friendId:String,
         date:Date) {
        self.friendUserName = friendUserName
        self.friendUserImageString = friendUserImageString
        self.lastMessage = lastMessage
        self.friendId = friendId
        self.date = date
    }
    
    //for init with ListenerService
    init?(documentSnap: QueryDocumentSnapshot){
          let documet = documentSnap.data()
          
        if let friendUserName = documet["friendUserName"] as? String {
            self.friendUserName = friendUserName
        } else { return nil }
        
        if let friendUserImageString = documet["friendUserImageString"] as? String {
            self.friendUserImageString = friendUserImageString
        } else { return nil }
        
        if let lastMessage =  documet["lastMessage"] as? String {
            self.lastMessage = lastMessage
        } else { return nil }
        
        if let friendId = documet["friendId"] as? String {
            self.friendId = friendId
        } else { return nil }
        
        if let date = documet["date"] as? Timestamp {
            self.date = date.dateValue()
        } else { return nil }

      }
    
    enum CodingKeys: String, CodingKey {
        case friendUserName
        case friendUserImageString
        case lastMessage
        case friendId
        case date
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(friendId)
    }
    
    static func == (lhs: MChat, rhs: MChat) -> Bool {
        return lhs.friendId == rhs.friendId
    }
    
    func contains(element: String?) -> Bool {
        guard let element = element else { return true }
        if element.isEmpty { return true }
        
        let lowercasedElement = element.lowercased()
        
        return friendUserName.lowercased().contains(lowercasedElement)
    }
}
