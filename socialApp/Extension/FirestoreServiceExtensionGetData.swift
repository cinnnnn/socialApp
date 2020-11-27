//
//  FirestoreExtensionGetData.swift
//  socialApp
//
//  Created by Денис Щиголев on 19.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

extension FirestoreService {
    //MARK: getPeople
    func getPeople(currentPeople: MPeople,
                   peoples: [MPeople],
                   likeChat: [MChat],
                   dislikeChat: [MChat],
                   acceptChat: [MChat],
                   complition: @escaping(Result<[MPeople], Error>)-> Void) {
        
        var peopleNearby: [MPeople] = []
        let likeChatID = likeChat.map { chat -> String in
            chat.friendId
        }
        let dislikeChatID = dislikeChat.map { chat -> String in
            chat.friendId
        }
        let acceptChatID = acceptChat.map { chat -> String in
            chat.friendId
        }
        let peopleID = peoples.map { people -> String in
            people.senderId
        }
        
        var usersID = likeChatID + dislikeChatID + acceptChatID + peopleID
        usersID.append(currentPeople.senderId)
        
        let minRange = currentPeople.searchSettings[MSearchSettings.minRange.rawValue] ?? MSearchSettings.minRange.defaultValue
        let maxRange = currentPeople.searchSettings[MSearchSettings.maxRange.rawValue] ?? MSearchSettings.maxRange.defaultValue
        
       
        var needCheckActiveUser = MSearchSettings.onlyActive.defaultValue == 0 ? false : true
        if let currentPeopleSettings = currentPeople.searchSettings[MSearchSettings.onlyActive.rawValue]  {
            needCheckActiveUser = currentPeopleSettings == 0 ? false : true
        }
       
        usersReference.whereField(
            MPeople.CodingKeys.isActive.rawValue, isEqualTo: true
        ).whereField(
            MPeople.CodingKeys.isBlocked.rawValue, isEqualTo: false
        ).whereField(
            MPeople.CodingKeys.isIncognito.rawValue, isEqualTo: false
        ).whereField(
            MPeople.CodingKeys.gender.rawValue, isEqualTo: MLookingFor.compareGender(gender: currentPeople.lookingFor)
        ).getDocuments { snapshot, error in
            if let error = error {
                complition(.failure(error))
            } else {
                guard let snapshot = snapshot else {
                    complition(.failure(FirestoreError.snapshotNotExist))
                    return
                }
                snapshot.documents.forEach { queryDocumentSnapshot in
                    if var people = MPeople(documentSnap: queryDocumentSnapshot) {
                        //check distance to people and append to him
                        let distance = LocationService.shared.getDistance(currentPeople: currentPeople, newPeople: people)
                        let range = currentPeople.searchSettings[MSearchSettings.distance.rawValue] ?? MSearchSettings.distance.defaultValue
                        //check dateOfBirth
                        let age = people.dateOfBirth.getAge()
                        //check is active
                        if needCheckActiveUser {
                            guard  people.lastActiveDate.checkIsActiveUser() else { return }
                        }
                        //check current people not in users array
                        guard !usersID.contains(people.senderId) else { return }
                        //check distance and age
                        if distance <= range && age >= minRange && age <= maxRange {
                            people.distance = distance
                            peopleNearby.append(people)
                        }
                    }
                }
                complition(.success(peopleNearby))
            }
        }
    }
    
    //MARK:  getUserData
    func getUserData(userID: String, complition: @escaping (Result<MPeople,Error>) -> Void) {
        
        let documentReference = usersReference.document(userID)
        documentReference.getDocument { (snapshot, error) in
            
            if let snapshot = snapshot, snapshot.exists {
                
                guard let people = MPeople(documentSnap: snapshot) else {
                    complition(.failure(UserError.incorrectSetProfile))
                    return
                }
                complition(.success(people))
                
            } else {
                complition(.failure(UserError.notAvailableUser))
            }
        }
    }
    
    //MARK: getUserCollection
    func getUserCollection(userID: String, collection: MFirestorCollection, complition: @escaping(Result<[MChat], Error>)->Void) {
        
        let reference = usersReference.document(userID).collection(collection.rawValue)
        var chats: [MChat] = []
        reference.getDocuments { snapshot, error in
            if let error = error {
                complition(.failure(error))
            }
            guard let snapshot = snapshot else {
                complition(.failure(FirestoreError.snapshotNotExist))
                return
            }
            snapshot.documents.forEach({ queryDocumentSnapshot in
                if let chat = MChat(documentSnap: queryDocumentSnapshot) {
                    chats.append(chat)
                }
            })
            complition(.success(chats))
        }
    }
}
