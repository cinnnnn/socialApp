//
//  MDislike.swift
//  socialApp
//
//  Created by Денис Щиголев on 02.12.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct MDislike: Hashable, Codable {
    var dislikePeopleID: String
    var date: Date
    
    init(dislikePeopleID: String, date: Date){
        self.dislikePeopleID = dislikePeopleID
        self.date = date
    }
    init?(documentSnap: QueryDocumentSnapshot ) {
        let document = documentSnap.data()
        
        if let dislikePeopleID = document["dislikePeopleID"] as? String {
            self.dislikePeopleID = dislikePeopleID
        } else { return nil }
        
        if let date = document["date"] as? Timestamp {
            self.date = date.dateValue()
        } else { return nil }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(dislikePeopleID)
    }

    static func == (lhs: MDislike, rhs: MDislike) -> Bool {
        return lhs.dislikePeopleID == rhs.dislikePeopleID
    }
}

