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
        guard let id = currentUser?.email else { fatalError("Cant get current user")}
        let collection = db.collection([MFirestorCollection.users.rawValue, id, MFirestorCollection.requestsChats.rawValue].joined(separator: "/"))
        return collection
    }
    
    private var likeRef: CollectionReference {
        guard let id = currentUser?.email else { fatalError("Cant get current user")}
        let collection = db.collection([MFirestorCollection.users.rawValue, id, MFirestorCollection.likePeople.rawValue].joined(separator: "/"))
        return collection
    }
    
    private var dislikeRef: CollectionReference {
        guard let id = currentUser?.email else { fatalError("Cant get current user")}
        let collection = db.collection([MFirestorCollection.users.rawValue, id, MFirestorCollection.dislikePeople.rawValue].joined(separator: "/"))
        return collection
    }
    
    private var acceptChatsRef: CollectionReference {
        guard let id = currentUser?.email else { fatalError("Cant get current user")}
        let collection = db.collection([MFirestorCollection.users.rawValue, id, MFirestorCollection.acceptChats.rawValue].joined(separator: "/"))
        return collection
    }
    
    private var peopleListner: ListenerRegistration?
    private var requestChatsListner: ListenerRegistration?
    private var likeListener: ListenerRegistration?
    private var dislikeListener: ListenerRegistration?
    private var acceptChatsListner: ListenerRegistration?
    private var messageListner: ListenerRegistration?
    
    private weak var peopleDelegate: PeopleListenerDelegate?
    private weak var requestChatDelegate: RequestChatListenerDelegate?
    private weak var likeDislikeDelegate: LikeDislikeListenerDelegate?
    private weak var acceptChatDelegate: AcceptChatListenerDelegate?
    
    
    private init() {}
    
    //MARK: peopleListener
    func addPeopleListener(peopleDelegate: PeopleListenerDelegate,
                           likeDislikeDelegate: LikeDislikeDelegate,
                           newActiveChatsDelegate: AcceptChatsDelegate) {
        
        self.peopleDelegate = peopleDelegate
        peopleListner = userRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            
            snapshot.documentChanges.forEach {[weak self] changes in
                guard var user = MPeople(documentSnap: changes.document) else { fatalError(UserError.getUserData.localizedDescription) }
                guard let people = self?.peopleDelegate?.peopleNearby else { fatalError(FirestoreError.peopleCollectionNotExist.localizedDescription) }
                
                if let currentPeople = UserDefaultsService.shared.getMpeople() {
                    user.distance = LocationService.shared.getDistance(currentPeople: currentPeople, newPeople: user)
                } else {
                    user.distance = Int.random(in: 0...30)
                }
                
                guard let currentUser = self?.currentUser else { return }
//                print("like \(likeDislikeDelegate.likePeople)")
//                print("dislike \(likeDislikeDelegate.dislikePeople)")
                
                switch changes.type {
                
                case .added:
                    if Validators.shared.listnerAddPeopleValidator(currentUser: currentUser,
                                                                   newPeople: user,
                                                                   peopleDelegate: peopleDelegate,
                                                                   likeDislikeDelegate: likeDislikeDelegate,
                                                                   acceptChatsDelegate: newActiveChatsDelegate,
                                                                   isUpdate: false) {
                        
                        self?.peopleDelegate?.peopleNearby.append(user)
                        self?.peopleDelegate?.reloadData(reloadSection: false)
                    }
                case .modified:
                    //index in peopleNearby array
                    if let index = people.firstIndex(of: user) {
                        if Validators.shared.listnerAddPeopleValidator(currentUser: currentUser,
                                                                       newPeople: user,
                                                                       peopleDelegate: peopleDelegate,
                                                                       likeDislikeDelegate: likeDislikeDelegate,
                                                                       acceptChatsDelegate: newActiveChatsDelegate,
                                                                       isUpdate: true) {
                            self?.peopleDelegate?.peopleNearby[index] = user
                            self?.peopleDelegate?.updateData()
                        } else { //if user change to deactive or block profile, delete him from collection
                            self?.peopleDelegate?.peopleNearby.remove(at: index)
                            self?.peopleDelegate?.reloadData(reloadSection: false)
                        }
                        //if user change to active profile, or unblock, add him to collection
                    } else if Validators.shared.listnerAddPeopleValidator(currentUser: currentUser,
                                                                          newPeople: user,
                                                                          peopleDelegate: peopleDelegate,
                                                                          likeDislikeDelegate: likeDislikeDelegate,
                                                                          acceptChatsDelegate: newActiveChatsDelegate,
                                                                          isUpdate: false) {
                        self?.peopleDelegate?.peopleNearby.append(user)
                        self?.peopleDelegate?.reloadData(reloadSection: false)
                    }
                    
                case .removed:
                    guard let index = people.firstIndex(of: user) else { return }
                    self?.peopleDelegate?.peopleNearby.remove(at: index)
                    self?.peopleDelegate?.reloadData(reloadSection: false)
                }
            }
        }
    }
    
    func removePeopleListener() {
        peopleListner?.remove()
    }
    
    //MARK: addLikeDislikeListener
    func addLikeDislikeListener(likeDislikeDelegate: LikeDislikeListenerDelegate) {
        self.likeDislikeDelegate = likeDislikeDelegate
        
        likeListener = likeRef.addSnapshotListener({ snapshot, error in
            guard let snapshot = snapshot else { return }
            
            snapshot.documentChanges.forEach {  changes in
                guard let chat = MChat(documentSnap: changes.document) else { fatalError(ChatError.getUserData.localizedDescription)}
                
                let likePeopleChats = likeDislikeDelegate.likePeople
                
                switch changes.type {
                
                case .added:
                    likeDislikeDelegate.likePeople.append(chat)
                case .modified:
                    if let index = likePeopleChats.firstIndex(of: chat) {
                        likeDislikeDelegate.likePeople[index] = chat
                    } else {
                        likeDislikeDelegate.likePeople.append(chat)
                    }
                case .removed:
                    if let index = likePeopleChats.firstIndex(of: chat) {
                        likeDislikeDelegate.likePeople.remove(at: index)
                    }
                }
            }
        })
        
        dislikeListener = dislikeRef.addSnapshotListener({ snapshot, error in
            guard let snapshot = snapshot else { fatalError(FirestoreError.snapshotNotExist.localizedDescription) }
            
            snapshot.documentChanges.forEach {  changes in
                guard let chat = MChat(documentSnap: changes.document) else { fatalError(ChatError.getUserData.localizedDescription)}
                
                let dislikePeopleChats = likeDislikeDelegate.dislikePeople
                
                switch changes.type {
                
                case .added:
                    likeDislikeDelegate.dislikePeople.append(chat)
                case .modified:
                    if let index = dislikePeopleChats.firstIndex(of: chat) {
                        likeDislikeDelegate.dislikePeople[index] = chat
                    } else {
                        likeDislikeDelegate.dislikePeople.append(chat)
                    }
                case .removed:
                    if let index = dislikePeopleChats.firstIndex(of: chat) {
                        likeDislikeDelegate.dislikePeople.remove(at: index)
                    }
                }
            }
        })
    }
    
    func removeLikeDislikeChatsListener() {
        likeListener?.remove()
        dislikeListener?.remove()
    }
    
    
    //MARK: requestChatsListener
    func addRequestChatsListener(delegate: RequestChatListenerDelegate) {
        self.requestChatDelegate = delegate
        self.requestChatsListner = requestChatsRef.addSnapshotListener({ snapshot, error in
            guard let snapshot = snapshot else { return }
            
            
            snapshot.documentChanges.forEach { [weak self] changes in
                guard var chat = MChat(documentSnap: changes.document) else { fatalError(ChatError.getUserData.localizedDescription)}
                
                guard let chats = self?.requestChatDelegate?.requestChats else {
                    fatalError(FirestoreError.chatsCollectionNotExist.localizedDescription) }
                
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
                                fatalError(FirestoreError.cantDeleteElementInCollection.localizedDescription)
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
    
    //MARK: acceptChatsListener
    func addAcceptChatsListener(delegate: AcceptChatListenerDelegate) {
        self.acceptChatDelegate = delegate
        self.acceptChatsListner = acceptChatsRef.addSnapshotListener({ snapshot, error in
            guard let snapshot = snapshot else { return }
            
            snapshot.documentChanges.forEach { [weak self] changes in
                guard var chat = MChat(documentSnap: changes.document) else { fatalError(ChatError.getUserData.localizedDescription)}
                
                guard let chats = self?.acceptChatDelegate?.acceptChats else {
                    fatalError(FirestoreError.chatsCollectionNotExist.localizedDescription) }
                
                //get actual information for user in chat
                FirestoreService.shared.getUserData(userID: chat.friendId) { result in
                    switch result {
                    
                    case .success(let people):
                        chat.friendUserImageString = people.userImage
                        chat.friendUserName = people.displayName
                        
                        switch changes.type {
                        
                        case .added:
                            self?.acceptChatDelegate?.acceptChats.append(chat)
                            self?.acceptChatDelegate?.reloadData(changeType: .addOrDelete)
                        case .modified:
                            if let index = chats.firstIndex(of: chat) {
                                self?.acceptChatDelegate?.acceptChats[index] = chat
                                self?.acceptChatDelegate?.reloadData(changeType: .update)
                            }
                        case .removed:
                            if let index = chats.firstIndex(of: chat) {
                                self?.acceptChatDelegate?.acceptChats.remove(at: index)
                                self?.acceptChatDelegate?.reloadData(changeType: .addOrDelete)
                            } else {
                                fatalError(FirestoreError.cantDeleteElementInCollection.localizedDescription)
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
    
    func removeAcceptChatsListener() {
        acceptChatsListner?.remove()
    }
    
    //MARK: messageListener
    func messageListener(chat:MChat, complition: @escaping (Result<MMessage,Error>)->Void) {
        
        messageListner = acceptChatsRef.document(chat.friendId).collection(MFirestorCollection.messages.rawValue).addSnapshotListener({ snapshot, error in
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

