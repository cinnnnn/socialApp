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
    
    private var currentPeople: MPeople?
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
    
    private init() {}
    
    //MARK: peopleListener
    func addPeopleListener(currentPeople: MPeople,
                           peopleDelegate: PeopleListenerDelegate,
                           likeDislikeDelegate: LikeDislikeListenerDelegate,
                           acceptChatsDelegate: AcceptChatListenerDelegate) {
        peopleListner = userRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { return }
            
            snapshot.documentChanges.forEach { changes in
                guard var user = MPeople(documentSnap: changes.document) else { fatalError(UserError.getUserData.localizedDescription) }
                let people = peopleDelegate.peopleNearby
                
                if let currentPeople = UserDefaultsService.shared.getMpeople() {
                    user.distance = LocationService.shared.getDistance(currentPeople: currentPeople, newPeople: user)
                } else {
                    user.distance = Int.random(in: 0...30)
                }
                
                switch changes.type {
                
                case .added:
                    
                    if Validators.shared.listnerAddPeopleValidator(currentPeople: currentPeople,
                                                                   newPeople: user,
                                                                   peopleDelegate: peopleDelegate,
                                                                   likeDislikeDelegate: likeDislikeDelegate,
                                                                   acceptChatsDelegate: acceptChatsDelegate,
                                                                   isUpdate: false) {
                       
                        peopleDelegate.peopleNearby.append(user)
                        peopleDelegate.reloadData(reloadSection: false, animating: true)
                    }
                case .modified:
                    //index in peopleNearby array
                    if let index = people.firstIndex(of: user) {
                        if Validators.shared.listnerAddPeopleValidator(currentPeople: currentPeople,
                                                                       newPeople: user,
                                                                       peopleDelegate: peopleDelegate,
                                                                       likeDislikeDelegate: likeDislikeDelegate,
                                                                       acceptChatsDelegate: acceptChatsDelegate,
                                                                       isUpdate: true) {
                            peopleDelegate.peopleNearby[index] = user
                            peopleDelegate.updateData()
                        } else { //if user change to deactive or block profile, delete him from collection
                            peopleDelegate.peopleNearby.remove(at: index)
                            peopleDelegate.reloadData(reloadSection: false, animating: true)
                        }
                        //if user change to active profile, or unblock, add him to collection
                    } else if Validators.shared.listnerAddPeopleValidator(currentPeople: currentPeople,
                                                                          newPeople: user,
                                                                          peopleDelegate: peopleDelegate,
                                                                          likeDislikeDelegate: likeDislikeDelegate,
                                                                          acceptChatsDelegate: acceptChatsDelegate,
                                                                          isUpdate: false) {
                        peopleDelegate.peopleNearby.append(user)
                        peopleDelegate.reloadData(reloadSection: false, animating: true)
                    }
                    
                case .removed:
                    guard let index = people.firstIndex(of: user) else { return }
                    peopleDelegate.peopleNearby.remove(at: index)
                    peopleDelegate.reloadData(reloadSection: false, animating: true)
                }
            }
        }
    }
    
    func removePeopleListener() {
        peopleListner?.remove()
    }
    
    //MARK: addLikeDislikeListener
    func addLikeDislikeListener(likeDislikeDelegate: LikeDislikeListenerDelegate) {
        
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
    func addRequestChatsListener(userID: String,
                                 requestChatDelegate: RequestChatListenerDelegate,
                                 likeDislikeDelegate: LikeDislikeListenerDelegate) {
        
        self.requestChatsListner = requestChatsRef.addSnapshotListener({ snapshot, error in
            guard let snapshot = snapshot else { return }
            
            snapshot.documentChanges.forEach { changes in
                guard var chat = MChat(documentSnap: changes.document) else { fatalError(ChatError.getUserData.localizedDescription)}
                
                let chats = requestChatDelegate.requestChats
                
                //get actual information for user in chat
                FirestoreService.shared.getUserData(userID: chat.friendId) { result in
                    switch result {
                    
                    case .success(let people):
                        chat.friendUserImageString = people.userImage
                        chat.friendUserName = people.displayName
                        
                        switch changes.type {
                        
                        case .added:
                            if Validators.shared.listnerAddRequestValidator(userID: userID,
                                                                            newRequestChat: chat,
                                                                            requestDelegate: requestChatDelegate,
                                                                            likeDislikeDelegate: likeDislikeDelegate) {
                                requestChatDelegate.requestChats.append(chat)
                                requestChatDelegate.reloadData(changeType: .add)
                            }
                            
                        case .modified:
                            if let index = chats.firstIndex(of: chat) {
                                requestChatDelegate.requestChats[index] = chat
                            } else {
                                if Validators.shared.listnerAddRequestValidator(userID: userID,
                                                                                newRequestChat: chat,
                                                                                requestDelegate: requestChatDelegate,
                                                                                likeDislikeDelegate: likeDislikeDelegate) {
                                    requestChatDelegate.requestChats.append(chat)
                                }
                            }
                            requestChatDelegate.reloadData(changeType: .update)
                            
                        case .removed:
                            if let index = chats.firstIndex(of: chat) {
                                requestChatDelegate.requestChats.remove(at: index)
                                requestChatDelegate.reloadData(changeType: .delete)
                            } else {
                                break
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
    func addAcceptChatsListener(acceptChatDelegate: AcceptChatListenerDelegate) {
        self.acceptChatsListner = acceptChatsRef.addSnapshotListener({ snapshot, error in
            guard let snapshot = snapshot else { return }
            
            snapshot.documentChanges.forEach { changes in
                guard var chat = MChat(documentSnap: changes.document) else { fatalError(ChatError.getUserData.localizedDescription)}
                
                
                switch changes.type {
                
                case .added:
                    //get actual information for user in chat
                    FirestoreService.shared.getUserData(userID: chat.friendId) { result in
                        switch result {
                        
                        case .success(let people):
                            chat.friendUserImageString = people.userImage
                            chat.friendUserName = people.displayName
                            
                            if !acceptChatDelegate.acceptChats.contains(chat) {
                                acceptChatDelegate.acceptChats.append(chat)
                                acceptChatDelegate.reloadData(changeType: .add, chat: chat, messageIsChanged: true)
                            }
                        //failure get people info
                        case .failure(let error):
                            fatalError(error.localizedDescription)
                        }
                    }
                    
                case .modified:
                    if let index = acceptChatDelegate.acceptChats.firstIndex(of: chat) {
                        let messageIsChange = acceptChatDelegate.acceptChats[index].lastMessage == chat.lastMessage ? false : true
                        acceptChatDelegate.acceptChats[index] = chat
                        acceptChatDelegate.reloadData(changeType: .update, chat: chat, messageIsChanged: messageIsChange)
                    }
                case .removed:
                    if let index = acceptChatDelegate.acceptChats.firstIndex(of: chat) {
                        acceptChatDelegate.acceptChats.remove(at: index)
                        acceptChatDelegate.reloadData(changeType: .delete, chat: chat, messageIsChanged: nil)
                    } else {
                        break
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
                    complition(.failure(MessageError.deleteChat))
                }
            }
        })
    }
    
    func removeMessageListener() {
        messageListner?.remove()
    }
}

