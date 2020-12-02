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
    var gallery: [String : MGalleryPhotoProperty]
    var mail: String
    var gender: String
    var dateOfBirth: Date
    var sexuality: String
    var lookingFor: String
    var interests: [String]
    var desires: [String]
    var isGoldMember: Bool
    var goldMemberDate: Date?
    var goldMemberPurches: MPurchases?
    var likeCount: Int
    var lastActiveDate: Date
    var lastLikeDate: Date
    var isTestUser: Bool
    var isIncognito: Bool
    var isBlocked: Bool
    var isAdmin: Bool
    var isActive: Bool
    var isFakeUser: Bool?
    var authType: MAuthType
    var reportList: [MReports]
    
    var searchSettings: [String: Int]
    var location: CLLocationCoordinate2D
    var distance: Int
    
    init(senderId: String,
         displayName: String,
         advert: String,
         userImage: String,
         gallery: [String : MGalleryPhotoProperty],
         mail: String,
         gender: String,
         dateOfBirth: Date,
         sexuality: String,
         lookingFor: String,
         interests: [String],
         desires: [String],
         isGoldMember: Bool,
         goldMemberDate: Date,
         goldMemeberPurches: MPurchases,
         likeCount: Int,
         lastActiveDate: Date,
         lastLikeDate: Date,
         isTestUser: Bool,
         isIncognito: Bool,
         isBlocked: Bool,
         isAdmin: Bool,
         isActive: Bool,
         isFakeUser: Bool,
         reportList: [MReports],
         authType: MAuthType,
         searchSettings: [String: Int],
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
        self.interests = interests
        self.desires = desires
        self.isGoldMember = isGoldMember
        self.goldMemberDate = goldMemberDate
        self.goldMemberPurches = goldMemeberPurches
        self.likeCount = likeCount
        self.lastActiveDate = lastActiveDate
        self.lastLikeDate = lastLikeDate
        self.isTestUser = isTestUser
        self.isIncognito = isIncognito
        self.isBlocked = isBlocked
        self.isAdmin = isAdmin
        self.isActive = isActive
        self.isFakeUser = isFakeUser
        self.reportList = reportList
        self.authType = authType
        self.searchSettings = searchSettings
        self.location = location
        self.distance = distance
    }
    
    //MARK: documentSnapshot
    // for get document from Firestore
    init?(documentSnap: DocumentSnapshot){
        guard let documet = documentSnap.data()  else { return nil }
        
        if let displayName = documet["displayName"] as? String { self.displayName = displayName } else { displayName = ""}
        if let advert = documet["advert"] as? String { self.advert = advert } else { self.advert = ""}
        if let userImage = documet["userImage"] as? String { self.userImage = userImage } else { self.userImage = "" }
        if let gallery = documet["gallery"] as? [String : [String : Any]] {
            self.gallery = [:]
            for image in gallery {
                self.gallery[image.key] = MGalleryPhotoProperty(json: image.value)
            }
        } else {
            self.gallery = [:]
        }
        if let gender = documet["gender"] as? String { self.gender = gender } else { self.gender = ""}
        if let dateOfBirth = documet["dateOfBirth"] as? Timestamp { self.dateOfBirth = dateOfBirth.dateValue() } else { self.dateOfBirth = Date()}
        if let sexuality = documet["sexuality"] as? String { self.sexuality = sexuality } else { self.sexuality = ""}
        if let lookingFor = documet["lookingFor"] as? String { self.lookingFor = lookingFor } else { self.lookingFor = ""}
        if let interests = documet["interests"] as? [String] { self.interests = interests } else { self.interests = [] }
        if let desires = documet["desires"] as? [String] { self.desires = desires } else { self.desires = [] }
        if let isGoldMember = documet["isGoldMember"] as? Bool { self.isGoldMember = isGoldMember } else { self.isGoldMember = false}
        if let goldMemberDate = documet["goldMemberDate"] as? Timestamp { self.goldMemberDate = goldMemberDate.dateValue() } else {
            self.goldMemberDate = nil
        }
        if let goldMemberPurches = documet["goldMemberPurches"] as? String { self.goldMemberPurches = MPurchases(rawValue: goldMemberPurches)} else {
            self.goldMemberPurches = nil
        }
        if let lastActiveDate = documet["lastActiveDate"] as? Timestamp  { self.lastActiveDate = lastActiveDate.dateValue() } else {
            self.lastActiveDate = Date()
        }
        if let lastLikeDate = documet["lastLikeDate"] as? Timestamp  { self.lastLikeDate = lastLikeDate.dateValue() } else {
            self.lastLikeDate = Date()
        }
        if let likeCount = documet["likeCount"] as? Int  { self.likeCount = likeCount } else {
            self.likeCount = 0
        }
        if let isIncognito = documet["isIncognito"] as? Bool  { self.isIncognito = isIncognito } else {
            self.isIncognito = false
        }
        if let isTestUser = documet["isTestUser"] as? Bool  { self.isTestUser = isTestUser } else {
            self.isTestUser = false
        }
        if let isBlocked = documet["isBlocked"] as? Bool { self.isBlocked = isBlocked } else { self.isBlocked = false}
        if let isAdmin = documet["isAdmin"] as? Bool { self.isAdmin = isAdmin } else { self.isAdmin = false}
        if let isActive = documet["isActive"] as? Bool { self.isActive = isActive} else { self.isActive = false}
        if let isFakeUser = documet["isFakeUser"] as? Bool { self.isFakeUser = isFakeUser} else { self.isFakeUser = nil}
        if let reportList = documet["reportList"] as? [[String : Any]] {
            self.reportList = []
            for report in reportList {
                self.reportList.append(MReports(json: report))
            }
        } else {
            self.reportList = []
        }
        if let location = documet["location"] as? [String:Double] {
            let latitude = location[MLocation.latitude.rawValue] ?? MLocation.latitude.defaultValue
            let longitude = location[MLocation.longitude.rawValue] ?? MLocation.longitude.defaultValue
            let clLocation = CLLocationCoordinate2D(latitude: latitude,
                                                    longitude: longitude)
            self.location = clLocation
        } else {
            self.location = CLLocationCoordinate2D(latitude: MLocation.latitude.defaultValue,
                                                        longitude: MLocation.longitude.defaultValue)
            
        }
        if let searchSettings = documet["searchSettings"] as? [String: Int] {
            if let distance = searchSettings[MSearchSettings.distance.rawValue] {
                self.searchSettings = [MSearchSettings.distance.rawValue : distance]
            } else { self.searchSettings = [MSearchSettings.distance.rawValue : MSearchSettings.distance.defaultValue] }
            
            if let minRange = searchSettings[MSearchSettings.minRange.rawValue] {
                self.searchSettings[MSearchSettings.minRange.rawValue] = minRange
            } else { self.searchSettings[MSearchSettings.minRange.rawValue] = MSearchSettings.minRange.defaultValue }
            
            if let maxRange = searchSettings[MSearchSettings.maxRange.rawValue] {
                self.searchSettings[MSearchSettings.maxRange.rawValue] = maxRange
            } else { self.searchSettings[MSearchSettings.maxRange.rawValue] = MSearchSettings.maxRange.defaultValue }
            
            if let currentLocation = searchSettings[MSearchSettings.currentLocation.rawValue] {
                self.searchSettings[MSearchSettings.currentLocation.rawValue] = currentLocation
            } else { self.searchSettings[MSearchSettings.currentLocation.rawValue] = MSearchSettings.currentLocation.defaultValue }
            
            if let onlyActive = searchSettings[MSearchSettings.onlyActive.rawValue] {
                self.searchSettings[MSearchSettings.onlyActive.rawValue] = onlyActive
            } else { self.searchSettings[MSearchSettings.onlyActive.rawValue] = MSearchSettings.onlyActive.defaultValue }
            
        } else {
            self.searchSettings = [MSearchSettings.distance.rawValue : MSearchSettings.distance.defaultValue,
                                   MSearchSettings.minRange.rawValue : MSearchSettings.minRange.defaultValue,
                                   MSearchSettings.maxRange.rawValue : MSearchSettings.maxRange.defaultValue,
                                   MSearchSettings.currentLocation.rawValue : MSearchSettings.currentLocation.defaultValue,
                                   MSearchSettings.onlyActive.rawValue : MSearchSettings.onlyActive.defaultValue ]
        }
        
        if let authType = documet["authType"] as? String {
            if let mAuthType = MAuthType(rawValue: authType) {
                self.authType = mAuthType
            } else {
                self.authType = MAuthType.defaultAuthType()
            }
        } else {
            self.authType = MAuthType.defaultAuthType()
        }
        
        guard let mail = documet["mail"] as? String else { return nil }
        guard let senderId = documet["senderId"] as? String else { return nil }
        
        self.distance = 0
        self.mail = mail
        self.senderId = senderId
    }
    
    //MARK: QueryDocumentSnapshot
    //for init with ListenerService
    init?(documentSnap: QueryDocumentSnapshot){
        let documet = documentSnap.data()
        
        if let displayName = documet["displayName"] as? String { self.displayName = displayName } else { displayName = ""}
        if let advert = documet["advert"] as? String { self.advert = advert } else { self.advert = ""}
        if let userImage = documet["userImage"] as? String { self.userImage = userImage } else { self.userImage = "" }
        if let gallery = documet["gallery"] as? [String : [String : Any]] {
            self.gallery = [:]
            for image in gallery {
                self.gallery[image.key] = MGalleryPhotoProperty(json: image.value)
            }
        } else {
            self.gallery = [:]
        }
        if let gender = documet["gender"] as? String { self.gender = gender } else { self.gender = ""}
        if let dateOfBirth = documet["dateOfBirth"] as? Timestamp { self.dateOfBirth = dateOfBirth.dateValue() } else { self.dateOfBirth = Date()}
        if let sexuality = documet["sexuality"] as? String { self.sexuality = sexuality } else { self.sexuality = ""}
        if let lookingFor = documet["lookingFor"] as? String { self.lookingFor = lookingFor } else { self.lookingFor = ""}
        if let interests = documet["interests"] as? [String] { self.interests = interests } else { self.interests = [] }
        if let desires = documet["desires"] as? [String] { self.desires = desires } else { self.desires = [] }
        if let isGoldMember = documet["isGoldMember"] as? Bool { self.isGoldMember = isGoldMember } else { self.isGoldMember = false}
        if let goldMemberDate = documet["goldMemberDate"] as? Timestamp { self.goldMemberDate = goldMemberDate.dateValue() } else {
            self.goldMemberDate = nil
        }
        if let lastActiveDate = documet["lastActiveDate"] as? Timestamp  { self.lastActiveDate = lastActiveDate.dateValue() } else {
            self.lastActiveDate = Date()
        }
        if let lastLikeDate = documet["lastLikeDate"] as? Timestamp  { self.lastLikeDate = lastLikeDate.dateValue() } else {
            self.lastLikeDate = Date()
        }
        if let goldMemberPurches = documet["goldMemberPurches"] as? String { self.goldMemberPurches = MPurchases(rawValue: goldMemberPurches)} else {
            self.goldMemberPurches = nil
        }
        if let likeCount = documet["likeCount"] as? Int  { self.likeCount = likeCount } else {
            self.likeCount = 0
        }
        if let isIncognito = documet["isIncognito"] as? Bool  { self.isIncognito = isIncognito } else {
            self.isIncognito = false
        }
        if let isTestUser = documet["isTestUser"] as? Bool  { self.isTestUser = isTestUser } else {
            self.isTestUser = false
        }
        if let isBlocked = documet["isBlocked"] as? Bool { self.isBlocked = isBlocked } else { self.isBlocked = false}
        if let isAdmin = documet["isAdmin"] as? Bool { self.isAdmin = isAdmin } else { self.isAdmin = false}
        if let isActive = documet["isActive"] as? Bool { self.isActive = isActive} else { self.isActive = false}
        if let isFakeUser = documet["isFakeUser"] as? Bool { self.isFakeUser = isFakeUser} else { self.isFakeUser = nil}
        if let reportList = documet["reportList"] as? [[String : Any]] {
            self.reportList = []
            for report in reportList {
                self.reportList.append(MReports(json: report))
            }
        } else {
            self.reportList = []
        }
        if let location = documet["location"] as? [String:Double] {
            let latitude = location[MLocation.latitude.rawValue] ?? MLocation.latitude.defaultValue
            let longitude = location[MLocation.longitude.rawValue] ?? MLocation.longitude.defaultValue
            let clLocation = CLLocationCoordinate2D(latitude: latitude,
                                                    longitude: longitude)
            self.location = clLocation
        } else { self.location = CLLocationCoordinate2D(latitude: MLocation.latitude.defaultValue,
                                                        longitude: MLocation.longitude.defaultValue)}
        
        if let searchSettings = documet["searchSettings"] as? [String: Int] {
            if let distance = searchSettings[MSearchSettings.distance.rawValue] {
                self.searchSettings = [MSearchSettings.distance.rawValue : distance]
            } else { self.searchSettings = [MSearchSettings.distance.rawValue : MSearchSettings.distance.defaultValue] }
            
            if let minRange = searchSettings[MSearchSettings.minRange.rawValue] {
                self.searchSettings[MSearchSettings.minRange.rawValue] = minRange
            } else { self.searchSettings[MSearchSettings.minRange.rawValue] = MSearchSettings.minRange.defaultValue }
            
            if let maxRange = searchSettings[MSearchSettings.maxRange.rawValue] {
                self.searchSettings[MSearchSettings.maxRange.rawValue] = maxRange
            } else { self.searchSettings[MSearchSettings.maxRange.rawValue] = MSearchSettings.maxRange.defaultValue }
            
            if let currentLocation = searchSettings[MSearchSettings.currentLocation.rawValue] {
                self.searchSettings[MSearchSettings.currentLocation.rawValue] = currentLocation
            } else { self.searchSettings[MSearchSettings.currentLocation.rawValue] = MSearchSettings.currentLocation.defaultValue }
        } else {
            self.searchSettings = [MSearchSettings.distance.rawValue : MSearchSettings.distance.defaultValue,
                                   MSearchSettings.minRange.rawValue : MSearchSettings.minRange.defaultValue,
                                   MSearchSettings.maxRange.rawValue : MSearchSettings.maxRange.defaultValue,
                                   MSearchSettings.currentLocation.rawValue : MSearchSettings.currentLocation.defaultValue]
        }
        if let authType = documet["authType"] as? String {
            if let mAuthType = MAuthType(rawValue: authType) {
                self.authType = mAuthType
            } else {
                self.authType = MAuthType.defaultAuthType()
            }
        } else {
            self.authType = MAuthType.defaultAuthType()
        }
        
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
        guard let gallery = data["gallery"] as? [String: MGalleryPhotoProperty] else { return nil}
        guard let gender = data["gender"] as? String else { return nil }
        guard let dateOfBirth = data["dateOfBirth"] as? Date else { return nil }
        guard let sexuality = data["sexuality"] as? String else { return nil }
        guard let lookingFor = data["lookingFor"] as? String else { return nil }
        guard let interests = data["interests"] as? [String] else { return nil }
        guard let desires = data["desires"] as? [String] else { return nil }
        guard let isGoldMember = data["isGoldMember"] as? Bool else { return nil }
        guard let goldMemberDate = data["goldMemberDate"] as? Date else { return nil }
        guard let goldMemberPurches = data["goldMemberPurches"] as? MPurchases else { return nil }
        guard let lastActiveDate = data["lastActiveDate"] as? Date else { return nil }
        guard let lastLikeDate = data["lastLikeDate"] as? Date else { return nil }
        guard let likeCount = data["likeCount"] as? Int else { return nil }
        guard let isIncognito = data["isIncognito"] as? Bool else { return nil }
        guard let isTestUser = data["isTestUser"] as? Bool else { return nil }
        guard let isBlocked = data["isBlocked"] as? Bool else { return nil }
        guard let isAdmin = data["isAdmin"] as? Bool else { return nil }
        guard let isActive = data["isActive"] as? Bool else { return nil }
        guard let isFakeUser = data["isFakeUser"] as? Bool else { return nil }
        guard let reportList = data["reportList"] as? [MReports] else { return nil }
        guard let location = data["location"] as? CLLocationCoordinate2D else { return nil }
        guard let mail = data["mail"] as? String else { return nil }
        guard let authType = data["authType"] as? MAuthType else { return nil }
        guard let searchSettings = data["searchSettings"] as? [String: Int] else { return nil}
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
        self.interests = interests
        self.desires = desires
        self.isGoldMember = isGoldMember
        self.goldMemberDate = goldMemberDate
        self.goldMemberPurches = goldMemberPurches
        self.lastActiveDate = lastActiveDate
        self.lastLikeDate = lastLikeDate
        self.likeCount = likeCount
        self.isIncognito = isIncognito
        self.isTestUser = isTestUser
        self.isBlocked = isBlocked
        self.isAdmin = isAdmin
        self.isActive = isActive
        self.isFakeUser = isFakeUser
        self.reportList = reportList
        self.location = location
        self.mail = mail
        self.authType = authType
        self.searchSettings = searchSettings
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
        case interests
        case desires
        case isGoldMember
        case goldMemberDate
        case goldMemberPurches
        case lastActiveDate
        case lastLikeDate
        case likeCount
        case isIncognito
        case isTestUser
        case isBlocked
        case isAdmin
        case isActive
        case isFakeUser
        case reportList
        case location
        case mail
        case authType
        case searchSettings
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
