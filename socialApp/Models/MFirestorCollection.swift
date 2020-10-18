//
//  MFirestorCollection.swift
//  socialApp
//
//  Created by Денис Щиголев on 17.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

enum MFirestorCollection: String, Codable {
    case users = "users"
    case requstsChats = "requestChats"
    case newChats = "newChats"
    case activeChats = "activeChats"
    case dislikePeople = "dislikePeople"
    case likePeople = "likePeople"
}
