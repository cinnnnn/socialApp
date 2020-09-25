//
//  ListenerService.swift
//  socialApp
//
//  Created by Денис Щиголев on 14.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Firebase
import FirebaseFirestore
import FirebaseAuth

class ListenerService {
    
    static let shared = ListenerService()
    
    private var currentUser: User? {
        Auth.auth().currentUser
    }
    private let db = Firestore.firestore()
    private var userRef: CollectionReference {
        db.collection("users")
    }
    private var requestChatsRef: CollectionReference {
        guard let user = currentUser else { fatalError("Cant get current user")}
        let collection = db.collection(["users", user.uid, "requestChats"].joined(separator: "/"))
        return collection
    }
    
    private var activeChatsRef: CollectionReference {
        guard let user = currentUser else { fatalError("Cant get current user")}
        let collection = db.collection(["users", user.uid, "activeChats"].joined(separator: "/"))
        return collection
    }
    private var peopleListner: ListenerRegistration?
    private var requestChatsListner: ListenerRegistration?
    private var activeChatsListner: ListenerRegistration?
    
    private weak var peopleDelegate: PeopleListenerDelegate?
    private weak var requestChatDelegate: RequestChatListenerDelegate?
    private weak var activeChatDelegate: ActiveChatListenerDelegate?
    
    
    private init() {}
    
    //MARK: peopleListener
    func addPeopleListener(delegate: PeopleListenerDelegate) {
        
        self.peopleDelegate = delegate
        peopleListner = userRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { fatalError(ListenerError.snapshotNotExist.localizedDescription) }
            
            snapshot.documentChanges.forEach {[weak self] changes in
                guard let user = MPeople(documentSnap: changes.document) else { fatalError(UserError.getUserData.localizedDescription) }
                guard let people = self?.peopleDelegate?.peopleNearby else { fatalError(ListenerError.peopleCollectionNotExist.localizedDescription) }
                switch changes.type {
                
                case .added:
                    guard !people.contains(user) else { return }
                    guard user.id != self?.currentUser?.uid else { return }
                    guard user.isActive == true else { return }
                    self?.peopleDelegate?.peopleNearby.append(user)
                    self?.peopleDelegate?.reloadData()
                    
                case .modified:
                    if let index = people.firstIndex(of: user) {
                        if user.isActive == true {
                            self?.peopleDelegate?.peopleNearby[index] = user
                            self?.peopleDelegate?.updateData()
                        } else { //if user change to deactive profile delete him from collection
                            self?.peopleDelegate?.peopleNearby.remove(at: index)
                            self?.peopleDelegate?.reloadData()
                        }
                        //if user change to active profile add him to collection
                    } else if user.isActive == true, user.id != self?.currentUser?.uid { 
                        self?.peopleDelegate?.peopleNearby.append(user)
                        self?.peopleDelegate?.reloadData()
                    }
                    
                case .removed:
                    guard let index = people.firstIndex(of: user) else { return }
                    self?.peopleDelegate?.peopleNearby.remove(at: index)
                    self?.peopleDelegate?.reloadData()
                }
            }
        }
    }
    
    func removePeopleListener() {
        peopleListner?.remove()
    }
    
    //MARK: requestChatsListener
    func addRequestChatsListener(delegate: RequestChatListenerDelegate) {
        self.requestChatDelegate = delegate
        self.requestChatsListner = requestChatsRef.addSnapshotListener({ snapshot, error in
            guard let snapshot = snapshot else { fatalError(ListenerError.snapshotNotExist.localizedDescription) }
            
            
            snapshot.documentChanges.forEach { [weak self] changes in
                guard var chat = MChat(documentSnap: changes.document) else { fatalError(ChatError.getUserData.localizedDescription)}
            
                guard let chats = self?.requestChatDelegate?.requestChats else {
                    fatalError(ListenerError.chatsCollectionNotExist.localizedDescription) }
                
                //get actual information for user in chat
                FirestoreService.shared.getUserData(userID: chat.friendId) { result in
                    switch result {
                    
                    case .success(let people):
                        chat.friendUserImageString = people.userImage
                        chat.friendUserName = people.userName
                        
                        switch changes.type {
                        
                        case .added:
                            self?.requestChatDelegate?.requestChats.append(chat)
                            self?.requestChatDelegate?.reloadRequestData()
                        case .modified:
                            if let index = chats.firstIndex(of: chat) {
                                self?.requestChatDelegate?.requestChats[index] = chat
                            } else {
                                self?.requestChatDelegate?.requestChats.append(chat)
                            }
                            self?.requestChatDelegate?.reloadRequestData()
                        case .removed:
                            if let index = chats.firstIndex(of: chat) {
                                self?.requestChatDelegate?.requestChats.remove(at: index)
                                self?.requestChatDelegate?.reloadRequestData()
                            } else {
                                fatalError(ListenerError.cantDeleteElementInCollection.localizedDescription)
                            }
                        }
                    //failure get people info
                    case .failure(let error):
                        fatalError(error.localizedDescription)
                    }
                }
            }
        })
    }
    
    func removeRequestChatsListener() {
        requestChatsListner?.remove()
    }
    
    //MARK: ActiveChatsListener
    func addActiveChatsListener(delegate: ActiveChatListenerDelegate) {
        self.activeChatDelegate = delegate
        self.activeChatsListner = activeChatsRef.addSnapshotListener({ snapshot, error in
            guard let snapshot = snapshot else { fatalError(ListenerError.snapshotNotExist.localizedDescription) }
            
            snapshot.documentChanges.forEach { [weak self] changes in
                guard var chat = MChat(documentSnap: changes.document) else { fatalError(ChatError.getUserData.localizedDescription)}
            
                guard let chats = self?.activeChatDelegate?.activeChats else {
                    fatalError(ListenerError.chatsCollectionNotExist.localizedDescription) }
                
                //get actual information for user in chat
                FirestoreService.shared.getUserData(userID: chat.friendId) { result in
                    switch result {
                    
                    case .success(let people):
                        chat.friendUserImageString = people.userImage
                        chat.friendUserName = people.userName
                        
                        switch changes.type {
                        
                        case .added:
                            self?.activeChatDelegate?.activeChats.append(chat)
                            self?.activeChatDelegate?.reloadActiveData()
                        case .modified:
                            if let index = chats.firstIndex(of: chat) {
                                self?.activeChatDelegate?.activeChats[index] = chat
                                self?.activeChatDelegate?.updateActiveData()
                            }
                        case .removed:
                            if let index = chats.firstIndex(of: chat) {
                                self?.activeChatDelegate?.activeChats.remove(at: index)
                                self?.activeChatDelegate?.reloadActiveData()
                            } else {
                                fatalError(ListenerError.cantDeleteElementInCollection.localizedDescription)
                            }
                        }
                    //failure get people info
                    case .failure(let error):
                        fatalError(error.localizedDescription)
                    }
                }
            }
        })
    }
    
    func removeActiveChatsListener() {
        activeChatsListner?.remove()
    }
}
