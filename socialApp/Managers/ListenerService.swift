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
    
    private var requestChatsListner: ListenerRegistration?
    private var likeListener: ListenerRegistration?
    private var dislikeListener: ListenerRegistration?
    private var acceptChatsListner: ListenerRegistration?
    private var messageListner: ListenerRegistration?
    
    private init() {}

    
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
                guard let dislike = MDislike(documentSnap: changes.document) else { fatalError(ChatError.getUserData.localizedDescription)}
                
                let dislikePeopleChats = likeDislikeDelegate.dislikePeople
                
                switch changes.type {
                
                case .added:
                    likeDislikeDelegate.dislikePeople.append(dislike)
                case .modified:
                    if let index = dislikePeopleChats.firstIndex(of: dislike) {
                        likeDislikeDelegate.dislikePeople[index] = dislike
                    } else {
                        likeDislikeDelegate.dislikePeople.append(dislike)
                    }
                case .removed:
                    if let index = dislikePeopleChats.firstIndex(of: dislike) {
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
                                 reportsDelegate: ReportsListnerDelegate) {
        
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
                                                                            reportsDelegate: reportsDelegate) {
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
                                                                                reportsDelegate: reportsDelegate) {
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
