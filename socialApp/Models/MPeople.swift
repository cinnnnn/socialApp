//
//  MPeople.swift
//  socialApp
//
//  Created by Денис Щиголев on 26.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct MPeople: Hashable, Decodable {
    var userName: String
    var advert: String
    var userImage: String
    var search: String
    var mail: String
    var sex: String
    var id: String
    
    
    init(userName: String,
         advert: String,
         userImage: String,
         search: String,
         mail: String,
         sex: String,
         id: String) {
        
        self.userName = userName
        self.advert = advert
        self.userImage = userImage
        self.search = search
        self.mail = mail
        self.sex = sex
        self.id = id
    }
    
    init?(documentSnap: DocumentSnapshot){
        guard let documet = documentSnap.data()  else { return nil }
        guard let username = documet["username"] as? String else { return nil }
        guard let advert = documet["advert"] as? String else { return nil }
        guard let userImage = documet["userImage"] as? String else { return nil }
        guard let search = documet["search"] as? String else { return nil }
        guard let mail = documet["mail"] as? String else { return nil }
        guard let sex = documet["sex"] as? String else { return nil }
        guard let id = documet["id"] as? String else { return nil }
        
        self.userName = username
        self.advert = advert
        self.userImage = userImage
        self.search = search
        self.mail = mail
        self.sex = sex
        self.id = id
    }
    
    var representation: [String: Any] {
        var rep = ["username": userName]
        rep["advert"] = advert
        rep["userImage"] = userImage
        rep["search"] = search
        rep["mail"] = mail
        rep["sex"] = sex
        rep["id"] = id
        return rep
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MPeople, rhs: MPeople) -> Bool {
        return lhs.id == rhs.id
    }
}
