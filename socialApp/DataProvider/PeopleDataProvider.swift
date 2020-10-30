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
    
    
    //MARK: work with listner
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
