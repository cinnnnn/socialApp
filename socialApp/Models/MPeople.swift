//
//  MPeople.swift
//  socialApp
//
//  Created by Денис Щиголев on 26.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation
import FirebaseFirestore
import MessageKit

struct MPeople: Hashable, Codable, SenderType {
    
    var displayName: String
    var advert: String
    var userImage: String
    var search: String
    var mail: String
    var sex: String
    var isActive: Bool
    var senderId: String
    
    
    init(displayName: String,
         advert: String,
         userImage: String,
         search: String,
         mail: String,
         sex: String,
         isActive: Bool,
         senderId: String) {
        
        self.displayName = displayName
        self.advert = advert
        self.userImage = userImage
        self.search = search
        self.mail = mail
        self.sex = sex
        self.isActive = isActive
        self.senderId = senderId
    }
    
    //for get document from Firestore
    init?(documentSnap: DocumentSnapshot){
        guard let documet = documentSnap.data()  else { return nil }
        if let displayName = documet["displayName"] as? String { self.displayName = displayName } else { displayName = ""}
        if let advert = documet["advert"] as? String { self.advert = advert } else { self.advert = ""}
        if let userImage = documet["userImage"] as? String { self.userImage = userImage } else { self.userImage = "" }
        if let search = documet["search"] as? String { self.search = search } else { self.search = ""}
        if let sex = documet["sex"] as? String { self.sex = sex } else { self.sex = ""}
        if let isActive = documet["isActive"] as? Bool { self.isActive = isActive} else { self.isActive = false}
        guard let mail = documet["mail"] as? String else { return nil }
        guard let senderId = documet["senderId"] as? String else { return nil }
        
        self.mail = mail
        self.senderId = senderId
    }
    
    //for init with ListenerService
    init?(documentSnap: QueryDocumentSnapshot){
        let documet = documentSnap.data()
        
        if let displayName = documet["displayName"] as? String { self.displayName = displayName } else { displayName = ""}
        if let advert = documet["advert"] as? String { self.advert = advert } else { self.advert = ""}
        if let userImage = documet["userImage"] as? String { self.userImage = userImage } else { self.userImage = "" }
        if let search = documet["search"] as? String { self.search = search } else { self.search = ""}
        if let sex = documet["sex"] as? String { self.sex = sex } else { self.sex = ""}
        if let isActive = documet["isActive"] as? Bool { self.isActive = isActive} else { self.isActive = false}
        guard let mail = documet["mail"] as? String else { return nil }
        guard let senderId = documet["senderId"] as? String else { return nil }
        self.mail = mail
        self.senderId = senderId
    }
    
    enum CodingKeys: String, CodingKey {
        case displayName
        case advert
        case userImage
        case search
        case mail
        case sex
        case isActive
        case senderId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(senderId)
    }
    
    static func == (lhs: MPeople, rhs: MPeople) -> Bool {
        return  lhs.senderId == rhs.senderId
    }
}
