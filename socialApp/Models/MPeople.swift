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
        
        if let userName = documet["username"] as? String { self.userName = userName } else { userName = ""}
        if let advert = documet["advert"] as? String { self.advert = advert } else { self.advert = ""}
        if let userImage = documet["userImage"] as? String { self.userImage = userImage } else {
            self.userImage = "https://firebasestorage.googleapis.com/v0/b/socialapp-aacc9.appspot.com/o/avatars%2Favatar%403x.png?alt=media&token=b31d0413-89bd-4927-b930-a69e8523f094"
        }
        if let search = documet["search"] as? String { self.search = search } else { self.search = ""}
        if let sex = documet["sex"] as? String { self.sex = sex } else { self.sex = ""}
        guard let mail = documet["mail"] as? String else { return nil }
        guard let id = documet["uid"] as? String else { return nil }
        
        self.mail = mail
        self.id = id
    }
    
    var representation: [String: Any] {
        var rep = ["username": userName]
        rep["advert"] = advert
        rep["userImage"] = userImage
        rep["search"] = search
        rep["mail"] = mail
        rep["sex"] = sex
        rep["uid"] = id
        return rep
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MPeople, rhs: MPeople) -> Bool {
        return lhs.id == rhs.id
    }
}
