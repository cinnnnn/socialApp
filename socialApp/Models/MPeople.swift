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
import MapKit

struct MPeople: Hashable, Codable, SenderType {
    
    var senderId: String
    var displayName: String
    var advert: String
    var userImage: String
    var gallery: [String]
    var mail: String
    var gender: String
    var dateOfBirth: Date
    var sexuality: String
    var lookingFor: String
    var goldMember: Bool
    var goldMemberDate: Date
    var isBlocked: Bool
    var isAdmin: Bool
    var isActive: Bool
    var reportList: [MReports:String]
    
    var location: CLLocationCoordinate2D
    var distance: Int
    
    init(senderId: String,
         displayName: String,
         advert: String,
         userImage: String,
         gallery: [String],
         mail: String,
         gender: String,
         dateOfBirth: Date,
         sexuality: String,
         lookingFor: String,
         goldMember: Bool,
         goldMemberDate: Date,
         isBlocked: Bool,
         isAdmin: Bool,
         isActive: Bool,
         reportList: [MReports:String],
         location: CLLocationCoordinate2D,
         distance: Int) {
        
        self.senderId = senderId
        self.displayName = displayName
        self.mail = mail
        self.advert = advert
        self.userImage = userImage
        self.gallery = gallery
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.sexuality = sexuality
        self.lookingFor = lookingFor
        self.goldMember = goldMember
        self.goldMemberDate = goldMemberDate
        self.isBlocked = isBlocked
        self.isAdmin = isAdmin
        self.isActive = isActive
        self.reportList = reportList
        self.location = location
        self.distance = distance
    }
    
    //for get document from Firestore
    init?(documentSnap: DocumentSnapshot){
        guard let documet = documentSnap.data()  else { return nil }
        if let displayName = documet["displayName"] as? String { self.displayName = displayName } else { displayName = ""}
        if let advert = documet["advert"] as? String { self.advert = advert } else { self.advert = ""}
        if let userImage = documet["userImage"] as? String { self.userImage = userImage } else { self.userImage = "" }
        if let gallery = documet["gallery"] as? [String] { self.gallery = gallery } else { self.gallery = []}
        if let gender = documet["gender"] as? String { self.gender = gender } else { self.gender = ""}
        if let dateOfBirth = documet["dateOfBirth"] as? Date { self.dateOfBirth = dateOfBirth } else { self.dateOfBirth = Date()}
        if let sexuality = documet["sexuality"] as? String { self.sexuality = sexuality } else { self.sexuality = ""}
        if let lookingFor = documet["lookingFor"] as? String { self.lookingFor = lookingFor } else { self.lookingFor = ""}
        if let goldMember = documet["goldMember"] as? Bool { self.goldMember = goldMember } else { self.goldMember = false}
        if let goldMemberDate = documet["goldMemberDate"] as? Date { self.goldMemberDate = goldMemberDate } else { self.goldMemberDate = Date()}
        if let isBlocked = documet["isBlocked"] as? Bool { self.isBlocked = isBlocked } else { self.isBlocked = false}
        if let isAdmin = documet["isAdmin"] as? Bool { self.isAdmin = isAdmin } else { self.isAdmin = false}
        if let isActive = documet["isActive"] as? Bool { self.isActive = isActive} else { self.isActive = false}
        if let reportList = documet["reportList"] as? [MReports:String] { self.reportList = reportList} else { self.reportList = [:]}
        if let location = documet["location"] as? [String:Double] {
            let latitude = location[MLocation.latitude.rawValue] ?? MLocation.latitude.defaultValue
            let longitude = location[MLocation.longitude.rawValue] ?? MLocation.longitude.defaultValue
            let clLocation = CLLocationCoordinate2D(latitude: latitude,
                                                    longitude: longitude)
            self.location = clLocation
        } else { self.location = CLLocationCoordinate2D(latitude: MLocation.latitude.defaultValue,
                                                        longitude: MLocation.longitude.defaultValue)}
        guard let mail = documet["mail"] as? String else { return nil }
        guard let senderId = documet["senderId"] as? String else { return nil }
        
        self.distance = 0
        self.mail = mail
        self.senderId = senderId
    }
    
    //for init with ListenerService
    init?(documentSnap: QueryDocumentSnapshot){
        let documet = documentSnap.data()
        
        if let displayName = documet["displayName"] as? String { self.displayName = displayName } else { displayName = ""}
        if let advert = documet["advert"] as? String { self.advert = advert } else { self.advert = ""}
        if let userImage = documet["userImage"] as? String { self.userImage = userImage } else { self.userImage = "" }
        if let gallery = documet["gallery"] as? [String] { self.gallery = gallery } else { self.gallery = []}
        if let gender = documet["gender"] as? String { self.gender = gender } else { self.gender = ""}
        if let dateOfBirth = documet["dateOfBirth"] as? Date { self.dateOfBirth = dateOfBirth } else { self.dateOfBirth = Date()}
        if let sexuality = documet["sexuality"] as? String { self.sexuality = sexuality } else { self.sexuality = ""}
        if let lookingFor = documet["lookingFor"] as? String { self.lookingFor = lookingFor } else { self.lookingFor = ""}
        if let goldMember = documet["goldMember"] as? Bool { self.goldMember = goldMember } else { self.goldMember = false}
        if let goldMemberDate = documet["goldMemberDate"] as? Date { self.goldMemberDate = goldMemberDate } else { self.goldMemberDate = Date()}
        if let isBlocked = documet["isBlocked"] as? Bool { self.isBlocked = isBlocked } else { self.isBlocked = false}
        if let isAdmin = documet["isAdmin"] as? Bool { self.isAdmin = isAdmin } else { self.isAdmin = false}
        if let isActive = documet["isActive"] as? Bool { self.isActive = isActive} else { self.isActive = false}
        if let reportList = documet["reportList"] as? [MReports:String] { self.reportList = reportList} else { self.reportList = [:]}
        if let location = documet["location"] as? [String:Double] {
            let latitude = location[MLocation.latitude.rawValue] ?? MLocation.latitude.defaultValue
            let longitude = location[MLocation.longitude.rawValue] ?? MLocation.longitude.defaultValue
            let clLocation = CLLocationCoordinate2D(latitude: latitude,
                                                    longitude: longitude)
            self.location = clLocation
        } else { self.location = CLLocationCoordinate2D(latitude: MLocation.latitude.defaultValue,
                                                        longitude: MLocation.longitude.defaultValue)}
        guard let mail = documet["mail"] as? String else { return nil }
        guard let senderId = documet["senderId"] as? String else { return nil }
        
        self.distance = 0
        self.mail = mail
        self.senderId = senderId
    }
    
    //for init UserDefaults
    init?(data: [String : Any]){
        
        guard let displayName = data["displayName"] as? String else { return nil }
        guard let advert = data["advert"] as? String else { return nil }
        guard let userImage = data["userImage"] as? String else { return nil }
        guard let gallery = data["gallery"] as? [String] else { return nil}
        guard let gender = data["gender"] as? String else { return nil }
        guard let dateOfBirth = data["dateOfBirth"] as? Date else { return nil }
        guard let sexuality = data["sexuality"] as? String else { return nil }
        guard let lookingFor = data["lookingFor"] as? String else { return nil }
        guard let goldMember = data["goldMember"] as? Bool else { return nil }
        guard let goldMemberDate = data["goldMemberDate"] as? Date else { return nil }
        guard let isBlocked = data["isBlocked"] as? Bool else { return nil }
        guard let isAdmin = data["isAdmin"] as? Bool else { return nil }
        guard let isActive = data["isActive"] as? Bool else { return nil }
        guard let reportList = data["reportList"] as? [MReports:String] else { return nil }
        guard let location = data["location"] as? CLLocationCoordinate2D else { return nil }
        guard let mail = data["mail"] as? String else { return nil }
        guard let senderId = data["senderId"] as? String else { return nil }
        guard let distance = data["distance"] as? Int else { return nil }
        
        self.displayName = displayName
        self.advert = advert
        self.userImage = userImage
        self.gallery = gallery
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.sexuality = sexuality
        self.lookingFor = lookingFor
        self.goldMember = goldMember
        self.goldMemberDate = goldMemberDate
        self.isBlocked = isBlocked
        self.isAdmin = isAdmin
        self.isActive = isActive
        self.reportList = reportList
        self.location = location
        self.mail = mail
        self.senderId = senderId
        self.distance = distance
    }
    
    enum CodingKeys: String, CodingKey {
        case displayName
        case advert
        case userImage
        case gallery
        case gender
        case dateOfBirth
        case sexuality
        case lookingFor
        case goldMember
        case goldMemberDate
        case isBlocked
        case isAdmin
        case isActive
        case reportList
        case location
        case mail
        case senderId
        case distance
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(senderId)
    }
    
    static func == (lhs: MPeople, rhs: MPeople) -> Bool {
        return  lhs.senderId == rhs.senderId
    }
}
