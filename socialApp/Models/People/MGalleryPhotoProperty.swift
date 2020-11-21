//
//  MGalleryPhotoProperty.swift
//  socialApp
//
//  Created by Денис Щиголев on 20.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

struct MGalleryPhotoProperty: Codable, Hashable{
    var isPrivate: Bool
    var index: Int
    
    init(isPrivate: Bool, index: Int){
        self.isPrivate = isPrivate
        self.index = index
    }
    
    init(json: [String: Any]) {
        if let isPrivate = json["isPrivate"] as? Bool {
            self.isPrivate = isPrivate
        } else {
            self.isPrivate = false
        }
        if let index = json["index"] as? Int {
            self.index = index
        } else {
            self.index = 0
        }
    }
    
    enum CodingKeys: String, CodingKey  {
        case isPrivate
        case index
    }
}

