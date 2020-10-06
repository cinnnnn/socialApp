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
import SDWebImage

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
        guard let email = currentUser?.email else { fatalError("Cant get current user")}
        let collection = db.collection(["users", email, "requestChats"].joined(separator: "/"))
        return collection
    }
    
    private var activeChatsRef: CollectionReference {
        guard let email = currentUser?.email else { fatalError("Cant get current user")}
        let collection = db.collection(["users", email, "activeChats"].joined(separator: "/"))
        return collection
    }
    private var peopleListner: ListenerRegistration?
    private var requestChatsListner: ListenerRegistration?
    private var activeChatsListner: ListenerRegistration?
    private var messageListner: ListenerRegistration?
    
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
                guard var user = MPeople(documentSnap: changes.document) else { fatalError(UserError.getUserData.localizedDescription) }
                guard let people = self?.peopleDelegate?.peopleNearby else { fatalError(ListenerError.peopleCollectionNotExist.localizedDescription) }
                
                if let currentPeople = UserDefaultsService.shared.getMpeople() {
                    user.distance = LocationService.shared.getDistance(currentPeople: currentPeople, newPeople: user)
                    print(user.distance)
                } else {
                    user.distance = Int.random(in: 0...30)
                }
                
                switch changes.type {
                
                case .added:
                    guard !people.contains(user) else { return }
                    guard user.senderId != self?.currentUser?.email else { return }
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
                    } else if user.isActive == true, user.senderId != self?.currentUser?.email {
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
                        chat.friendUserName = people.displayName
                        
                        switch changes.type {
                        
                        case .added:
                            self?.requestChatDelegate?.requestChats.append(chat)
                            self?.requestChatDelegate?.reloadData(changeType: .addOrDelete)
                        case .modified:
                            if let index = chats.firstIndex(of: chat) {
                                self?.requestChatDelegate?.requestChats[index] = chat
                            } else {
                                self?.requestChatDelegate?.requestChats.append(chat)
                            }
                            self?.requestChatDelegate?.reloadData(changeType: .update)
                        case .removed:
                            if let index = chats.firstIndex(of: chat) {
                                self?.requestChatDelegate?.requestChats.remove(at: index)
                                self?.requestChatDelegate?.reloadData(changeType: .addOrDelete)
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
                        chat.friendUserName = people.displayName
                        
                        switch changes.type {
                        
                        case .added:
                            self?.activeChatDelegate?.activeChats.append(chat)
                            self?.activeChatDelegate?.reloadData(changeType: .addOrDelete)
                        case .modified:
                            if let index = chats.firstIndex(of: chat) {
                                self?.activeChatDelegate?.activeChats[index] = chat
                                self?.activeChatDelegate?.reloadData(changeType: .update)
                            }
                        case .removed:
                            if let index = chats.firstIndex(of: chat) {
                                self?.activeChatDelegate?.activeChats.remove(at: index)
                                self?.activeChatDelegate?.reloadData(changeType: .addOrDelete)
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
    
    //MARK: messageListener
    func messageListener(chat:MChat, complition: @escaping (Result<MMessage,Error>)->Void) {
        
        messageListner = activeChatsRef.document(chat.friendId).collection("messages").addSnapshotListener({ snapshot, error in
            guard let snapshot = snapshot else { fatalError("Cant get snapshot of message")}
            
            snapshot.documentChanges.forEach { document in
                
                guard var message = MMessage(documentSnap: document.document) else {
                    complition(.failure(MessageError.getMessageData))
                    return
                }
                //if message has URL download image and put the message
                
                //message type change to .photo
                if message.imageURL != nil {
                    message.image = #imageLiteral(resourceName: "imageSend")
                }
                //message type .text
                switch document.type {
                
                case .added:
                    complition(.success(message))
                case .modified:
                    break
                case .removed:
                    break
                }
            }
        })
    }
    
    func removeMessageListener() {
        messageListner?.remove()
    }
}
