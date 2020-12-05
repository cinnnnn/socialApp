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
    
    func reloadData(reloadSection: Bool, animating: Bool, scrollToFirst: Bool) {
        peopleCollectionViewDelegate?.reloadData(reloadSection: reloadSection, animating: animating, scrollToFirst: scrollToFirst)
    }
}

extension PeopleDataProvider {
    //MARK:  get requestChats
    func getPeople(currentPeople: MPeople,
                   likeDislikeDelegate: LikeDislikeListenerDelegate,
                   acceptChatsDelegate: AcceptChatListenerDelegate,
                   reportsDelegate: ReportsListnerDelegate,
                   complition: @escaping (Result<[MPeople], Error>) -> Void) {
        
        FirestoreService.shared.getPeople(currentPeople: currentPeople,
                                          likeChat: likeDislikeDelegate.likePeople,
                                          dislikeChat: likeDislikeDelegate.dislikePeople,
                                          acceptChat: acceptChatsDelegate.acceptChats,
                                          reports: reportsDelegate.reports) {[weak self] result in
            switch result {
            
            case .success(let peoples):
                self?.peopleNearby = peoples
                
                self?.reloadData(reloadSection: peoples.count == 1 ? true : false, animating: false, scrollToFirst: true)
                complition(.success(peoples))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    
    //delete people
    func deletePeople(peopleID: String) {
        let peopleIndex = peopleNearby.firstIndex { currentPeople -> Bool in
            currentPeople.senderId == peopleID
        }
        guard let index = peopleIndex else { return }
        peopleNearby.remove(at: index)
        reloadData(reloadSection: peopleNearby.count == 1 ? true : false, animating: true, scrollToFirst: false)
    }
}

