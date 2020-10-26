//
//  MSender.swift
//  socialApp
//
//  Created by Денис Щиголев on 25.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import MessageKit

struct MSender: SenderType {
    private let adminID = "Admin"
    private let adminDisplayName = "Команда Chi"
    
    var senderId: String
    var displayName: String
}

extension MSender {
    
    static func getAdminSender() -> MSender {
        MSender(senderId: MAdmin.id.rawValue, displayName: MAdmin.displayName.rawValue)
    }
}
