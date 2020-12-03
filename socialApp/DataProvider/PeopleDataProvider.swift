//
//  PeopleDataProvider.swift
//  socialApp
//
//  Created by Денис Щиголев on 29.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

class PeopleDataProvider: PeopleListenerDelegate {
    
    weak var peopleCollectionViewDelegate: PeopleCollectionViewDelegate?
    
    var peopleNearby: [MPeople] = []
    var sortedPeopleNearby: [MPeople] {
        peopleNearby.sorted { p1, p2  in
            p1.distance < p2.distance
        }
    }
    var userID: String
    
    init(userID: String) {
        self.userID = userID
    }
    
    
    //MARK: work with collectionView
    func updateData() {
        peopleCollectionViewDelegate?.updateData()
    }
    
    func reloadData(reloadSection: Bool, animating: Bool) {
        peopleCollectionViewDelegate?.reloadData(reloadSection: reloadSection, animating: animating)
    }
}

extension PeopleDataProvider {
    //MARK:  get requestChats
    func getPeople(currentPeople: MPeople,
                   likeDislikeDelegate: LikeDislikeListenerDelegate,
                   acceptChatsDelegate: AcceptChatListenerDelegate,
                   complition: @escaping (Result<[MPeople], Error>) -> Void) {
    
        FirestoreService.shared.getPeople(currentPeople: currentPeople,
                                          peoples: peopleNearby,
                                          likeChat: likeDislikeDelegate.likePeople,
                                          dislikeChat: likeDislikeDelegate.dislikePeople,
                                          acceptChat: acceptChatsDelegate.acceptChats) {[weak self] result in
            switch result {
            
            case .success(let peoples):
                self?.peopleNearby = peoples
                
                self?.reloadData(reloadSection: peoples.count == 1 ? true : false, animating: false)
                complition(.success(peoples))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    
    func reloadPeople(currentPeople: MPeople,
                    likeDislikeDelegate: LikeDislikeListenerDelegate,
                    acceptChatsDelegate: AcceptChatListenerDelegate,
                    complition: @escaping (Result<[MPeople], Error>) -> Void) {
        peopleNearby = []
        getPeople(currentPeople: currentPeople,
                  likeDislikeDelegate: likeDislikeDelegate,
                  acceptChatsDelegate: acceptChatsDelegate) {[weak self] result in
            switch result {
            
            case .success(let peoples):
                self?.peopleNearby = peoples
                
                //if peoples count 1, need reload section to correct update collectionView
                self?.reloadData(reloadSection: peoples.count == 1 ? true : false, animating: false)
                complition(.success(peoples))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
}

