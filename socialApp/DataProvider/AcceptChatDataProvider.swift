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
    weak var messageCollectionViewDelegate: MessageControllerDelegate?
    
    init(userID: String) {
        self.userID = userID
    }
    
    func reloadData(changeType: MTypeOfListenerChanges, chat: MChat?) {
        
        switch changeType {
        case .add:
            acceptChatCollectionViewDelegate?.reloadDataSource(changeType: changeType)
        case .delete:
            acceptChatCollectionViewDelegate?.reloadDataSource(changeType: changeType)
        case .update:
            //if chat update, send to messageCollectionView this chat
            if let chat = chat {
                messageCollectionViewDelegate?.chatsCollectionWasUpdate(chat: chat)
            }
            acceptChatCollectionViewDelegate?.reloadDataSource(changeType: changeType)
        }
    }
}

extension AcceptChatDataProvider {
    func setupAcceptChatListener() {
        ListenerService.shared.addAcceptChatsListener(acceptChatDelegate: self)
    }
    
    func removeAcceptChatListener() {
        ListenerService.shared.removeAcceptChatsListener()
    }
}

//MARK:  getAcceptChats
extension AcceptChatDataProvider {
     func getAcceptChats(complition: @escaping (Result<[MChat], Error>) -> Void) {
        
        //first get list of like people
        FirestoreService.shared.getUserCollection(userID: userID,
                                                  collection: MFirestorCollection.acceptChats) {[weak self] result in
            
            switch result {
            
            case .success(let acceptChats):
                self?.acceptChats = acceptChats
                self?.checkInactiveChat()
                complition(.success(acceptChats))
            case .failure(let error):
                complition(.failure(error))
            }
        }
    }
}

//MARK: checkInactiveChat
extension AcceptChatDataProvider {
    //check chat for timeOfLife
    func checkInactiveChat() {
        let strongUserID = userID

        let periodMinutesOfLifeChat = MChat.getDefaultPeriodMinutesOfLifeChat()
        let checkInterval = TimeInterval(1)
        Timer.scheduledTimer(withTimeInterval: checkInterval,
                             repeats: true) {[weak self] timer in
            timer.tolerance = 0.5
            self?.acceptChats.forEach { acceptChat in
                //if timer doesn't stop, than check period
                if !acceptChat.timerOfLifeIsStoped {
                    if acceptChat.createChatDate.checkPeriodIsPassed(periodMinuteCount: periodMinutesOfLifeChat) {
                        FirestoreService.shared.deleteChat(currentUserID: strongUserID, friendID: acceptChat.friendId)
                    }
                }
            }
        }
    }
}
