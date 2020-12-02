//
//  LikeDislikeChatDataProvider.swift
//  socialApp
//
//  Created by Денис Щиголев on 29.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation

class LikeDislikeChatDataProvider: LikeDislikeListenerDelegate {
    
    var likePeople: [MChat] = []
    var dislikePeople: [MDislike] = []
    var userID: String
    
    init(userID: String){
        self.userID =  userID
    }
}

extension LikeDislikeChatDataProvider {
    //MARK:  get like dislike
     func getLike(complition: @escaping (Result<[MChat], Error>) -> Void) {
        FirestoreService.shared.getUserCollection(userID: userID,
                                                  collection: MFirestorCollection.likePeople) {[weak self] result in
            switch result {
            
            case .success(let likeChats):
                self?.likePeople = likeChats
                complition(.success(likeChats))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
    
    //MARK:  get  dislike
     func getDislike(complition: @escaping (Result<[MDislike], Error>) -> Void) {
        FirestoreService.shared.getDislikes(userID: userID) {[weak self] result in
            switch result {
            
            case .success(let dislikeChats):
                self?.dislikePeople = dislikeChats
                complition(.success(dislikeChats))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
}
