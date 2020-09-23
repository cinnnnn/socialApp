//
//  MPeople.swift
//  socialApp
//
//  Created by Денис Щиголев on 26.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct MPeople: Hashable, Codable {
    var userName: String
    var advert: String
    var userImage: String
    var search: String
    var mail: String
    var sex: String
    var isActive: Bool
    var id: String
    
    
    init(userName: String,
         advert: String,
         userImage: String,
         search: String,
         mail: String,
         sex: String,
         isActive: Bool,
         id: String) {
        
        self.userName = userName
        self.advert = advert
        self.userImage = userImage
        self.search = search
        self.mail = mail
        self.sex = sex
        self.isActive = isActive
        self.id = id
    }
    
    //for get document from Firestore
    init?(documentSnap: DocumentSnapshot){
        guard let documet = documentSnap.data()  else { return nil }
        if let userName = documet["userName"] as? String { self.userName = userName } else { userName = ""}
        if let advert = documet["advert"] as? String { self.advert = advert } else { self.advert = ""}
        if let userImage = documet["userImage"] as? String { self.userImage = userImage } else { self.userImage = "" }
        if let search = documet["search"] as? String { self.search = search } else { self.search = ""}
        if let sex = documet["sex"] as? String { self.sex = sex } else { self.sex = ""}
        if let isActive = documet["isActive"] as? Bool { self.isActive = isActive} else { self.isActive = false}
        guard let mail = documet["mail"] as? String else { return nil }
        guard let id = documet["uid"] as? String else { return nil }
        
        self.mail = mail
        self.id = id
    }
    
    //for init with ListenerService
    init?(documentSnap: QueryDocumentSnapshot){
          let documet = documentSnap.data()
          
          if let userName = documet["userName"] as? String { self.userName = userName } else { userName = ""}
          if let advert = documet["advert"] as? String { self.advert = advert } else { self.advert = ""}
          if let userImage = documet["userImage"] as? String { self.userImage = userImage } else {self.userImage = "" }
          if let search = documet["search"] as? String { self.search = search } else { self.search = ""}
          if let sex = documet["sex"] as? String { self.sex = sex } else { self.sex = ""}
          if let isActive = documet["isActive"] as? Bool { self.isActive = isActive} else { self.isActive = false}
          guard let mail = documet["mail"] as? String else { return nil }
          guard let id = documet["uid"] as? String else { return nil }
          
          self.mail = mail
          self.id = id
      }
    
    enum CodingKeys: String, CodingKey {
        case userName
        case advert
        case userImage
        case search
        case mail
        case sex
        case isActive
        case id = "uid"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MPeople, rhs: MPeople) -> Bool {
        return  lhs.id == rhs.id
    }
}
