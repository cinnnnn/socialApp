//
//  MPeople.swift
//  socialApp
//
//  Created by Денис Щиголев on 26.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

struct MPeople: Hashable, Decodable {
    var userName: String
    var message: String
    var userImageString: String
    var like: Bool
    var id: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MPeople, rhs: MPeople) -> Bool {
        return lhs.id == rhs.id
    }
}
