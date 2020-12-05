//
//  FirestoreService.swift
//  socialApp
//
//  Created by Денис Щиголев on 07.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

class FirestoreService {
    
    static let shared = FirestoreService()
    
     let db = Firestore.firestore()
     var usersReference: CollectionReference {
        db.collection(MFirestorCollection.users.rawValue)
    }
    
    private init() {}
    
    //MARK:  saveBaseProfile
    func saveBaseProfile(id: String,
                         email: String,
                         authType: MAuthType,
                         complition: @escaping (Result<String, Error>) -> Void){
        
        let authTypeString = authType.rawValue
        //save base user info to cloud FireStore
        usersReference.document(id).setData([MPeople.CodingKeys.senderId.rawValue : id,
                                             MPeople.CodingKeys.mail.rawValue: email,
                                             MPeople.CodingKeys.authType.rawValue: authTypeString],
                                            merge: true,
                                            completion: { (error) in
                                                if let error = error {
                                                    fatalError(error.localizedDescription)
                                                } else {
                                                    complition(.success(id))
                                                }
                                            })
    }
    
    //MARK:  saveFirstSetupDateOfBirth
    func saveFirstSetupDateOfBirth(id: String,
                                   dateOfBirth: Date,
                                   complition: @escaping (Result<Void, Error>) -> Void){
        usersReference.document(id).setData([MPeople.CodingKeys.dateOfBirth.rawValue: dateOfBirth],
                                            merge: true,
                                            completion: { error in
                                                if let error = error {
                                                    complition(.failure(error))
                                                } else {
                                                    complition(.success(()))
                                                }
                                            })
    }
    //MARK: saveInterests
    func saveInterests(id: String,
                       interests: [String],
                       complition: @escaping (Result<[String], Error>) -> Void) {
        usersReference.document(id).setData([MPeople.CodingKeys.interests.rawValue : interests],
                                            merge: true) { error in
            if let error = error {
                complition(.failure(error))
            } else {
                complition(.success(interests))
            }
        }
    }
    
    //MARK: saveDesires
    func saveDesires(id: String,
                     desires: [String],
                     complition: @escaping (Result<[String], Error>) -> Void) {
        usersReference.document(id).setData([MPeople.CodingKeys.desires.rawValue : desires],
                                            merge: true) { error in
            if let error = error {
                complition(.failure(error))
            } else {
                complition(.success(desires))
            }
        }
    }
    
    //MARK: saveIsGoldMember
    func saveIsGoldMember(id: String,
                          isGoldMember: Bool,
                          goldMemberDate: Date?,
                          goldMemberPurches: MPurchases?,
                          complition: @escaping (Result<MPeople, Error>) -> Void){
        var dictinaryForSave: [String : Any] = [MPeople.CodingKeys.isGoldMember.rawValue: isGoldMember,
                                                MPeople.CodingKeys.lastActiveDate.rawValue : Date()]
        if let goldMemberPurches = goldMemberPurches {
            dictinaryForSave[MPeople.CodingKeys.goldMemberPurches.rawValue] = goldMemberPurches.rawValue
        }
        if let goldMemberDate = goldMemberDate {
            dictinaryForSave[MPeople.CodingKeys.goldMemberDate.rawValue] = goldMemberDate
        }
    
        usersReference.document(id).setData(dictinaryForSave,
                                            merge: true,
                                            completion: { error in
                                                if let error = error {
                                                    complition(.failure(error))
                                                } else {
                                                    if var people = UserDefaultsService.shared.getMpeople() {
                                                        people.isGoldMember = isGoldMember
                                                        people.goldMemberDate = goldMemberDate
                                                        people.goldMemberPurches = goldMemberPurches
                                                        people.lastActiveDate = Date()
                                                        
                                                        UserDefaultsService.shared.saveMpeople(people: people)
                                                        NotificationCenter.postCurrentUserNeedUpdate()
                                                        NotificationCenter.postPremiumUpdate()
                                                        complition(.success(people))
                                                    } else {
                                                        complition(.failure(UserDefaultsError.cantGetData))
                                                    }
                                                }
                                            })
    }
    
    //MARK: setDefaultPremiumSettings
    func setDefaultPremiumSettings(currentPeople: MPeople, complition: @escaping (Result<MPeople, Error>) -> Void) {
        
        var imageWithPrivate: [String : Any] = [:]
        for image in currentPeople.gallery {
            if image.value.isPrivate {
                imageWithPrivate[image.key] = [ MGalleryPhotoProperty.CodingKeys.isPrivate.rawValue : false,
                                                MGalleryPhotoProperty.CodingKeys.index.rawValue : image.value.index]
            }
        }
        
        var dictinaryForSave: [String : Any] = [:]
        //set to default premium search settings
        dictinaryForSave[MPeople.CodingKeys.searchSettings.rawValue] =  [MSearchSettings.onlyActive.rawValue : MSearchSettings.onlyActive.defaultValue]
        //set to default incognito status
        dictinaryForSave = [MPeople.CodingKeys.isIncognito.rawValue : false]
        //set private photo to public if have them
        if !imageWithPrivate.isEmpty {
            dictinaryForSave[MPeople.CodingKeys.gallery.rawValue] = imageWithPrivate
        }
        usersReference.document(currentPeople.senderId).setData(dictinaryForSave,
                                                                merge: true) { error in
            if let error = error {
                complition(.failure(error))
            } else {
                if var people = UserDefaultsService.shared.getMpeople() {
                    people.searchSettings[MSearchSettings.onlyActive.rawValue] = MSearchSettings.onlyActive.defaultValue
                    people.isIncognito = false
                    imageWithPrivate.forEach { key, value in
                        people.gallery[key]?.isPrivate = false
                    }
                    UserDefaultsService.shared.saveMpeople(people: people)
                    NotificationCenter.postCurrentUserNeedUpdate()
                    NotificationCenter.postSearchSettingsNeedUpdate()
                }
            }
        }
    }
    
    //MARK:  addLikeCount
    func addLikeCount(currentPeople: MPeople, complition: @escaping (Result<MPeople,Error>)-> Void) {
        let freeLikeCount = 10
        
        var currentLikeCount = currentPeople.likeCount
        
        //check last like for do need reset count
        if currentPeople.lastLikeDate.checkIsToday() {
            currentLikeCount += 1
        } else {
            currentLikeCount = 0
        }
        
        guard currentLikeCount <= freeLikeCount || currentPeople.isGoldMember || currentPeople.isTestUser else {
            complition(.failure(UserError.freeCountOfLike))
            return
        }
        
        usersReference.document(currentPeople.senderId).setData([MPeople.CodingKeys.likeCount.rawValue : currentLikeCount,
                                                                 MPeople.CodingKeys.lastLikeDate.rawValue : Date(),
                                                                 MPeople.CodingKeys.lastActiveDate.rawValue : Date()],
                                                                merge: true)
        
        if var people = UserDefaultsService.shared.getMpeople() {
            people.likeCount = currentLikeCount == 0 ? 0 : currentLikeCount + 1
            people.lastLikeDate = Date()
            people.lastActiveDate = Date()
            UserDefaultsService.shared.saveMpeople(people: people)
            NotificationCenter.postCurrentUserNeedUpdate()
            complition(.success(people))
        } else {
            complition(.failure(UserDefaultsError.cantGetData))
        }
    }
    
    //MARK:  updateLastActiveDate
    func updateLastActiveDate(id: String) {
        usersReference.document(id).updateData([MPeople.CodingKeys.lastActiveDate.rawValue : Date()])
    }
    
    //MARK:  saveFirstSetupNameGender
    func saveFirstSetupNameGender(id: String,
                                  userName: String,
                                  gender: String,
                                  lookingFor: String,
                                  sexuality: String,
                                  complition: @escaping (Result<Void, Error>) -> Void) {
        
        let searchSettings = [MSearchSettings.distance.rawValue : MSearchSettings.distance.defaultValue,
                              MSearchSettings.minRange.rawValue : MSearchSettings.minRange.defaultValue,
                              MSearchSettings.maxRange.rawValue : MSearchSettings.maxRange.defaultValue,
                              MSearchSettings.currentLocation.rawValue : MSearchSettings.currentLocation.defaultValue]
        let reportList: [String:Any] = [:]
        
        usersReference.document(id).setData([MPeople.CodingKeys.displayName.rawValue : userName,
                                             MPeople.CodingKeys.gender.rawValue : gender,
                                             MPeople.CodingKeys.lookingFor.rawValue : lookingFor,
                                             MPeople.CodingKeys.sexuality.rawValue : sexuality,
                                             MPeople.CodingKeys.isActive.rawValue: true,
                                             MPeople.CodingKeys.isAdmin.rawValue: false,
                                             MPeople.CodingKeys.isBlocked.rawValue: false,
                                             MPeople.CodingKeys.isGoldMember.rawValue: false,
                                             MPeople.CodingKeys.isTestUser.rawValue: false,
                                             MPeople.CodingKeys.isIncognito.rawValue: false,
                                             MPeople.CodingKeys.searchSettings.rawValue: searchSettings,
                                             MPeople.CodingKeys.reportList.rawValue : FieldValue.arrayUnion([reportList])],
                                            merge: true,
                                            completion: { (error) in
                                                if let error = error {
                                                    complition(.failure(error))
                                                } else {
                                                    complition(.success(()))
                                                }
                                            })
    }
    
    //MARK:  saveFirstSetupAdvert
    func saveAdvert(id: String,
                    advert: String,
                    complition: @escaping (Result<Void, Error>) -> Void){
        usersReference.document(id).setData([MPeople.CodingKeys.advert.rawValue: advert],
                                            merge: true,
                                            completion: { error in
                                                if let error = error {
                                                    complition(.failure(error))
                                                } else {
                                                    complition(.success(()))
                                                }
                                            })
    }
    
    
    
    //MARK:  saveProfileAfterEdit
    func saveProfileAfterEdit(id: String,
                              name: String,
                              advert: String,
                              gender: String,
                              sexuality: String,
                              interests: [String],
                              desires: [String],
                              isIncognito: Bool,
                              complition: @escaping (Result<Void,Error>) -> Void) {
        usersReference.document(id).setData([MPeople.CodingKeys.displayName.rawValue : name,
                                             MPeople.CodingKeys.advert.rawValue : advert,
                                             MPeople.CodingKeys.gender.rawValue : gender,
                                             MPeople.CodingKeys.sexuality.rawValue : sexuality,
                                             MPeople.CodingKeys.isIncognito.rawValue : isIncognito,
                                             MPeople.CodingKeys.interests.rawValue : interests,
                                             MPeople.CodingKeys.desires.rawValue : desires,
                                             MPeople.CodingKeys.lastActiveDate.rawValue : Date()],
                                            merge: true) { error in
            if let error = error {
                complition(.failure(error))
            } else {
                //edit current user from UserDefaults for save request to server
                if var people = UserDefaultsService.shared.getMpeople() {
                    people.displayName = name
                    people.advert = advert
                    people.gender = gender
                    people.sexuality = sexuality
                    people.isIncognito = isIncognito
                    people.interests = interests
                    people.desires = desires
                    people.lastActiveDate = Date()
                    UserDefaultsService.shared.saveMpeople(people: people)
                    NotificationCenter.postCurrentUserNeedUpdate()
                }
                complition(.success(()))
            }
        }
    }
    
    //MARK:  saveSearchSettings
    func saveSearchSettings(id: String,
                            distance: Int,
                            minRange: Int,
                            maxRange: Int,
                            currentLocation: Int,
                            lookingFor: String,
                            onlyActive: Int,
                            complition: @escaping (Result<MPeople, Error>) -> Void) {
        
        let searchSettings = [MSearchSettings.distance.rawValue : distance,
                              MSearchSettings.minRange.rawValue : minRange,
                              MSearchSettings.maxRange.rawValue : maxRange,
                              MSearchSettings.currentLocation.rawValue : currentLocation,
                              MSearchSettings.onlyActive.rawValue : onlyActive]
        
        usersReference.document(id).setData([MPeople.CodingKeys.lookingFor.rawValue : lookingFor,
                                             MPeople.CodingKeys.searchSettings.rawValue: searchSettings,
                                             MPeople.CodingKeys.lastActiveDate.rawValue : Date()],
                                            merge: true,
                                            completion: { (error) in
                                                if let error = error {
                                                    complition(.failure(error))
                                                } else {
                                                    //save people to UserDefaults for save request to server
                                                    if var people = UserDefaultsService.shared.getMpeople() {
                                                        people.lookingFor = lookingFor
                                                        people.searchSettings = searchSettings
                                                        people.lastActiveDate = Date()
                                                        UserDefaultsService.shared.saveMpeople(people: people)
                                                        NotificationCenter.postCurrentUserNeedUpdate()
                                                        NotificationCenter.postSearchSettingsNeedUpdate()
                                                        complition(.success(people))
                                                    } else {
                                                        complition(.failure(UserDefaultsError.cantGetData))
                                                    }
                                                }
                                            })
    }
    
    
    //MARK: saveLocation
    func saveLocation(userID: String, longitude: Double, latitude: Double, complition: @escaping (Result<[String:Double],Error>) -> Void) {
        usersReference.document(userID).setData([MPeople.CodingKeys.location.rawValue : [MLocation.longitude.rawValue:longitude,
                                                                                         MLocation.latitude.rawValue:latitude]],
                                                merge: true) { error in
            if let error = error {
                complition(.failure(error))
            } else {
                complition(.success([MLocation.longitude.rawValue:longitude,
                                     MLocation.latitude.rawValue:latitude]))
            }
        }
    }
    
  
}

extension FirestoreService {
    //MARK: getAlldocument
     func getAlldocument<T:ReprasentationModel>(type: T.Type ,collection: CollectionReference, complition:@escaping([T])-> Void) {
        var elements = [T]()
        var element: T?
        collection.getDocuments { snapshot, error in
            guard let snapshot = snapshot else { fatalError("Cant get collection snapshot")}
            
            snapshot.documents.forEach { document in
                element = T(documentSnap: document)
                guard let elementTType = element else { fatalError("Cant convert doc to T type")}
                elements.append(elementTType)
            }
            complition(elements)
        }
    }
    
    //MARK: deleteCollection
    //with inside document
     func  deleteCollection(collection: CollectionReference, batchSize: Int = 500) {
        // Limit query to avoid out-of-memory errors on large collections.
        // When deleting a collection guaranteed to fit in memory, batching can be avoided entirely.
        collection.limit(to: batchSize).getDocuments { docset, error in
            // An error occurred.
            guard let docset = docset else { fatalError("Cant get collection") }
            
            let batch = collection.firestore.batch()
            docset.documents.forEach { batch.deleteDocument($0.reference) }
            
            batch.commit {_ in
                //   self.deleteCollection(collection: collection, batchSize: batchSize)
            }
        }
    }
}
