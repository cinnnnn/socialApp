//
//  MShortPeople.swift
//  socialApp
//
//  Created by Денис Щиголев on 17.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct MShortPeople: Hashable, Codable {
    var userName: String
    var userImageString: String
    var userId: String
    var date: Date
    
    init(userName: String,
         userImageString: String,
         userId:String,
         date:Date) {
        self.userName = userName
        self.userImageString = userImageString
        self.userId = userId
        self.date = date
    }
    
    //for init with ListenerService
    init?(documentSnap: QueryDocumentSnapshot){
          let documet = documentSnap.data()
          
        if let userName = documet["userName"] as? String {
            self.userName = userName
        } else { return nil }
        
        if let userImageString = documet["userImageString"] as? String {
            self.userImageString = userImageString
        } else { return nil }
        
        if let userId = documet["userId"] as? String {
            self.userId = userId
        } else { return nil }
        
        if let date = documet["date"] as? Timestamp {
            self.date = date.dateValue()
        } else { return nil }

      }
    
    enum CodingKeys: String, CodingKey {
        case userName
        case userImageString
        case userId
        case date
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(userId)
    }
    
    static func == (lhs: MShortPeople, rhs: MShortPeople) -> Bool {
        return lhs.userId == rhs.userId
    }
    

}
