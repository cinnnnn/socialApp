//
//  MChat.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct MChat: Hashable, Codable, ReprasentationModel {
    var friendUserName: String
    var friendUserImageString: String
    var lastMessage: String
    var isNewChat: Bool
    var friendId: String
    var unreadChatMessageCount: Int
    var friendIsWantStopTimer: Bool
    var currentUserIsWantStopTimer: Bool
    var timerOfLifeIsStoped: Bool
    var createChatDate: Date
    var date: Date
    
    init(friendUserName: String,
         friendUserImageString: String,
         lastMessage: String,
         isNewChat: Bool,
         friendId:String,
         unreadChatMessageCount: Int,
         friendIsWantStopTimer: Bool,
         currentUserIsWantStopTimer: Bool,
         timerOfLifeIsStoped: Bool,
         createChatDate: Date,
         date:Date) {
        self.friendUserName = friendUserName
        self.friendUserImageString = friendUserImageString
        self.lastMessage = lastMessage
        self.isNewChat = isNewChat
        self.friendId = friendId
        self.unreadChatMessageCount = unreadChatMessageCount
        self.friendIsWantStopTimer = friendIsWantStopTimer
        self.currentUserIsWantStopTimer = currentUserIsWantStopTimer
        self.timerOfLifeIsStoped = timerOfLifeIsStoped
        self.createChatDate = createChatDate
        self.date = date
    }
    
    //MARK: QueryDocumentSnapshot
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
        
        if let isNewChat =  documet["isNewChat"] as? Bool {
            self.isNewChat = isNewChat
        } else { return nil }
        
        if let friendId = documet["friendId"] as? String {
            self.friendId = friendId
        } else { return nil }
        
        if let unreadChatMessageCount = documet["unreadChatMessageCount"] as? Int {
            self.unreadChatMessageCount = unreadChatMessageCount
        } else { return nil }
        
        if let friendIsWantStopTimer = documet["friendIsWantStopTimer"] as? Bool {
            self.friendIsWantStopTimer = friendIsWantStopTimer
        } else { return nil }
        
        if let currentUserIsWantStopTimer = documet["currentUserIsWantStopTimer"] as? Bool {
            self.currentUserIsWantStopTimer = currentUserIsWantStopTimer
        } else { return nil }
        
        if let timerOfLifeIsStoped = documet["timerOfLifeIsStoped"] as? Bool {
            self.timerOfLifeIsStoped = timerOfLifeIsStoped
        } else { return nil }
        
        if let createChatDate = documet["createChatDate"] as? Timestamp {
            self.createChatDate = createChatDate.dateValue()
        } else { return nil }
        
        if let date = documet["date"] as? Timestamp {
            self.date = date.dateValue()
        } else { return nil }
      }
    
    //MARK: DocumentSnapshot
    //for get document from Firestore
    init?(documentSnap: DocumentSnapshot){
        guard let documet = documentSnap.data()  else { return nil }
          
        if let friendUserName = documet["friendUserName"] as? String {
            self.friendUserName = friendUserName
        } else { return nil }
        
        if let friendUserImageString = documet["friendUserImageString"] as? String {
            self.friendUserImageString = friendUserImageString
        } else { return nil }
        
        if let lastMessage =  documet["lastMessage"] as? String {
            self.lastMessage = lastMessage
        } else { return nil }
        
        if let isNewChat =  documet["isNewChat"] as? Bool {
            self.isNewChat = isNewChat
        } else { return nil }
        
        if let friendId = documet["friendId"] as? String {
            self.friendId = friendId
        } else { return nil }
        
        if let unreadChatMessageCount = documet["unreadChatMessageCount"] as? Int {
            self.unreadChatMessageCount = unreadChatMessageCount
        } else { return nil }
        
        if let friendIsWantStopTimer = documet["friendIsWantStopTimer"] as? Bool {
            self.friendIsWantStopTimer = friendIsWantStopTimer
        } else { return nil }
        
        if let currentUserIsWantStopTimer = documet["currentUserIsWantStopTimer"] as? Bool {
            self.currentUserIsWantStopTimer = currentUserIsWantStopTimer
        } else { return nil }
        
        if let timerOfLifeIsStoped = documet["timerOfLifeIsStoped"] as? Bool {
            self.timerOfLifeIsStoped = timerOfLifeIsStoped
        } else { return nil }
        
        if let createChatDate = documet["createChatDate"] as? Timestamp {
            self.createChatDate = createChatDate.dateValue()
        } else { return nil }
        
        if let date = documet["date"] as? Timestamp {
            self.date = date.dateValue()
        } else { return nil }
      }
    
    //MARK: reprasentation
    var reprasentation: [String:Any] {
        let rep:[String: Any] = [
            "friendUserName": friendUserName,
            "friendUserImageString": friendUserImageString,
            "lastMessage": lastMessage,
            "isNewChat": isNewChat,
            "friendId": friendId,
            "unreadChatMessageCount": unreadChatMessageCount,
            "friendIsWantStopTimer": friendIsWantStopTimer,
            "currentUserIsWantStopTimer": currentUserIsWantStopTimer,
            "timerOfLifeIsStoped": timerOfLifeIsStoped,
            "createChatDate": createChatDate,
            "date": date
        ]
        return rep
    }
    
    //MARK: CodingKeys
    enum CodingKeys: String, CodingKey {
        case friendUserName
        case friendUserImageString
        case lastMessage
        case isNewChat
        case friendId
        case unreadChatMessageCount
        case friendIsWantStopTimer
        case currentUserIsWantStopTimer
        case timerOfLifeIsStoped
        case createChatDate
        case date
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(friendId)
    }
    
    static func == (lhs: MChat, rhs: MChat) -> Bool {
        return lhs.friendId == rhs.friendId
    }
    
    static func getDefaultPeriodMinutesOfLifeChat() -> Int {
        //period of life is 1440 minute = 1 day
        1440
    }
    
    func contains(element: String?) -> Bool {
        guard let element = element else { return true }
        if element.isEmpty { return true }
        
        let lowercasedElement = element.lowercased()
        
        return friendUserName.lowercased().contains(lowercasedElement)
    }
    
    func containsID(ID: String?) -> Bool {
        guard let ID = ID else { return false }
        
        let lowercasedID = ID.lowercased()
        
        return friendId.lowercased().contains(lowercasedID)
    }
}
