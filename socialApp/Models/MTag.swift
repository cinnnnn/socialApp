//
//  MTag.swift
//  socialApp
//
//  Created by Денис Щиголев on 24.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

struct MTag: Hashable {
    let tagText: String
    var isSelect: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(tagText)
        hasher.combine(isSelect)
    }
    
    static func == (lhs: MTag, rhs: MTag) -> Bool {
        return lhs.tagText == rhs.tagText && lhs.isSelect == rhs.isSelect
    }
}
