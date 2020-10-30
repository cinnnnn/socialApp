//
//  RequestChatDataProvider.swift
//  socialApp
//
//  Created by Денис Щиголев on 29.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

class RequestChatDataProvider: RequestChatListenerDelegate {
    
    var userID: String
    var requestChats: [MChat] = []
    var sortedRequestChats: [MChat] {
        let request = requestChats.sorted {
            $0.date > $1.date
        }
        return request
    }
    var requestChatCollectionViewDelegate: RequestChatCollectionViewDelegate?
   
    init(userID: String) {
        self.userID = userID
    }
}

extension RequestChatDataProvider {
    //MARK: setup listner
    func setupListener(likeDislikeDelegate: LikeDislikeListenerDelegate) {
        requestChats = []
        ListenerService.shared.addRequestChatsListener(userID: userID,
                                                       requestChatDelegate: self,
                                                       likeDislikeDelegate: likeDislikeDelegate)
    }
    
    //MARK: remove listner
    func removeListener() {
        ListenerService.shared.removeRequestChatsListener()
    }
    
    //MARK: reload listner
    func reloadListener(currentPeople: MPeople, likeDislikeDelegate: LikeDislikeListenerDelegate) {
        requestChats = []
        
        requestChatCollectionViewDelegate?.reloadData()
        //reload request listner
        removeListener()
        setupListener(likeDislikeDelegate: likeDislikeDelegate)
    }
    
    //MARK: reloadData
    func reloadData(changeType: MTypeOfListenerChanges) {
        requestChatCollectionViewDelegate?.reloadData()
    }
}

extension RequestChatDataProvider {
    //MARK:  get requestChats
    func getRequestChats(complition: @escaping (Result<[MChat], Error>) -> Void) {
    
        FirestoreService.shared.getUserCollection(userID: userID,
                                                  collection: MFirestorCollection.likePeople) {[weak self] result in
            switch result {
            
            case .success(let requestChats):
                self?.requestChats = requestChats
                complition(.success(requestChats))
                
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
}