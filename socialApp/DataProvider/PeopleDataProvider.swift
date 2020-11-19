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
                self?.reloadData(reloadSection: false, animating: false)
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
                self?.reloadData(reloadSection: false, animating: false)
                complition(.success(peoples))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
}

//MARK: - work with listner
extension PeopleDataProvider {
    
    func setupListener(currentPeople: MPeople, likeDislikeDelegate: LikeDislikeListenerDelegate, acceptChatsDelegate: AcceptChatListenerDelegate) {
        
        ListenerService.shared.addPeopleListener(currentPeople: currentPeople,
                                                 peopleDelegate: self,
                                                 likeDislikeDelegate: likeDislikeDelegate,
                                                 acceptChatsDelegate: acceptChatsDelegate)
    }
    
    func removeListener() {
        ListenerService.shared.removePeopleListener()
    }
    
    func reloadListener(currentPeople: MPeople, likeDislikeDelegate: LikeDislikeListenerDelegate, acceptChatsDelegate: AcceptChatListenerDelegate) {
        peopleNearby = []
      //  guard let updatePeople = UserDefaultsService.shared.getMpeople() else { return }
        removeListener()
        reloadData(reloadSection: false, animating: false)
        setupListener(currentPeople: currentPeople, likeDislikeDelegate: likeDislikeDelegate, acceptChatsDelegate: acceptChatsDelegate)
    }
    
}
