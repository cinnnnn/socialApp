//
//  MAuthType.swift
//  socialApp
//
//  Created by Денис Щиголев on 28.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

enum MAuthType: String, Codable {
    case appleID
    case email
}

extension MAuthType {
    
    static func defaultAuthType() -> MAuthType {
        MAuthType.appleID
    }
}

