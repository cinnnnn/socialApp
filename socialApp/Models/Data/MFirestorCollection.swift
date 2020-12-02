//
//  MFirestorCollection.swift
//  socialApp
//
//  Created by Денис Щиголев on 17.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

enum MFirestorCollection: String, Codable {
    case users = "users"
    case messages = "messages"
    case requestsChats = "requestChats"
    case requestMessage = "requestMessage"
    case acceptChats = "acceptChats"
    case activeChats = "activeChats"
    case dislikePeople = "dislikePeople"
    case reportUser = "reportPeople"
    case likePeople = "likePeople"
}
