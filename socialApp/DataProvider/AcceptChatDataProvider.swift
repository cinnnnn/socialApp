//
//  AcceptChatDataProvider.swift
//  socialApp
//
//  Created by Денис Щиголев on 29.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class AcceptChatDataProvider: AcceptChatListenerDelegate {
    
    var userID: String
    var acceptChats: [MChat] = []
    var sortedAcceptChats: [MChat] {
        let accept = acceptChats.sorted {
            $0.date > $1.date
        }
        return accept
    }
    
    weak var acceptChatCollectionViewDelegate: AcceptChatCollectionViewDelegate?
    
    init(userID: String) {
        self.userID = userID
    }
    
    func reloadData(changeType: MTypeOfListenerChanges) {
        
        switch changeType {
        case .addOrDelete:
            acceptChatCollectionViewDelegate?.reloadDataSource(searchText: nil)
            
        case .update:
            acceptChatCollectionViewDelegate?.updateDataSource(searchText: nil)
        }
    }
}

extension AcceptChatDataProvider {
    func setupListener() {
        acceptChats = []
        ListenerService.shared.addAcceptChatsListener(acceptChatDelegate: self)
    }
    
    func removeListener() {
        ListenerService.shared.removeAcceptChatsListener()
    }
}
extension AcceptChatDataProvider {
    //MARK:  setupListeners
     func getAcceptChats(complition: @escaping (Result<[MChat], Error>) -> Void) {
        
        let strongSelf = self
        //first get list of like people
        FirestoreService.shared.getUserCollection(userID: userID,
                                                  collection: MFirestorCollection.acceptChats) {[weak self] result in
            
            switch result {
            
            case .success(let acceptChats):
                self?.acceptChats = acceptChats
                //get list of dislike people
                ListenerService.shared.addAcceptChatsListener(acceptChatDelegate: strongSelf )
                complition(.success(acceptChats))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
}
