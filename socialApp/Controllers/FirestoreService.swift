//
//  FirestoreService.swift
//  socialApp
//
//  Created by Денис Щиголев on 07.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase
import FirebaseAuth

class FirestoreService {
    
    static let shared = FirestoreService()
    
    private init() {}
    
    private let db = Firestore.firestore()
    
    private var usersReference: CollectionReference {
        db.collection("users")
    }
    
    //MARK:  saveAvatar
    func saveAvatar(image: UIImage?, user: User, complition: @escaping (Result<String, Error>) -> Void) {
        
        guard let avatar = image else { fatalError("cant get userProfile image") }
        //if user choose photo, than upload new photo to Storage
        if  image != #imageLiteral(resourceName: "avatar")  {
            StorageService.shared.uploadImage(image: avatar) {[weak self] result in
                switch result {
                
                case .success(let url):
                    let userImageString = url.absoluteString
                    //save user to FireStore
                    self?.usersReference.document(user.uid).setData([MPeople.CodingKeys.userImage.rawValue : userImageString], merge: true, completion: { error in
                        if let error = error {
                            complition(.failure(error))
                        } else {
                            complition(.success(userImageString))
                        }
                    })
                case .failure(_):
                    fatalError("Cant upload Image")
                }
            }
        }
    }
    
    //MARK:  saveBaseProfile
    func saveBaseProfile(id: String,
                         email: String,
                         complition: @escaping (Result<Void, Error>) -> Void){
        
        //save base user info to cloud FireStore
        usersReference.document(id).setData([MPeople.CodingKeys.senderId.rawValue : id,
                                             MPeople.CodingKeys.mail.rawValue: email,
                                             MPeople.CodingKeys.isActive.rawValue: false],
                                            merge: true,
                                            completion: { (error) in
                                                if let error = error {
                                                    fatalError(error.localizedDescription)
                                                } else {
                                                    complition(.success(()))
                                                }
                                            })
    }
    //MARK:  saveGender
    func saveGender(user: User, gender: String, complition: @escaping (Result<Void, Error>) -> Void) {
        usersReference.document(user.uid).setData([MPeople.CodingKeys.sex.rawValue : gender],
                                                  merge: true,
                                                  completion: { (error) in
                                                    if let error = error {
                                                        complition(.failure(error))
                                                    } else {
                                                        complition(.success(()))
                                                    }
                                                  })
    }
    
    //MARK:  saveWant
    func saveWant(user: User, want: String, complition: @escaping (Result<Void, Error>) -> Void) {
        usersReference.document(user.uid).setData([MPeople.CodingKeys.search.rawValue : want],
                                                  merge: true,
                                                  completion: { (error) in
                                                    if let error = error {
                                                        complition(.failure(error))
                                                    } else {
                                                        complition(.success(()))
                                                    }
                                                  })
    }
    
    //MARK:  saveDefaultImage
    func saveDefaultImage(user: User, defaultImageString: String, complition: @escaping (Result<Void, Error>) -> Void) {
        usersReference.document(user.uid).setData([MPeople.CodingKeys.userImage.rawValue : defaultImageString],
                                                  merge: true,
                                                  completion: { (error) in
                                                    if let error = error {
                                                        complition(.failure(error))
                                                    } else {
                                                        complition(.success(()))
                                                    }
                                                  })
    }
    
    //MARK: - saveAdvertAndName
    func saveAdvertAndName(user: User,
                           userName: String,
                           advert: String,
                           isActive: Bool,
                           complition: @escaping (Result<Void, Error>) -> Void){
        usersReference.document(user.uid).setData([MPeople.CodingKeys.displayName.rawValue : userName,
                                                   MPeople.CodingKeys.advert.rawValue: advert,
                                                   MPeople.CodingKeys.isActive.rawValue: isActive],
                                                  merge: true,
                                                  completion: { (error) in
                                                    if let error = error {
                                                        complition(.failure(error))
                                                    } else {
                                                        complition(.success(()))                                                    }
                                                  })
    }
    
    //MARK:  getUserData
    func getUserData(userID: String, complition: @escaping (Result<MPeople,Error>) -> Void) {
        
        let documentReference = usersReference.document(userID)
        documentReference.getDocument { (snapshot, error) in
            
            if let snapshot = snapshot, snapshot.exists {
                
                guard let people = MPeople(documentSnap: snapshot) else {
                    complition(.failure(UserError.incorrectSetProfile))
                    return
                }
                complition(.success(people))
                
            } else {
                complition(.failure(UserError.notAvailableUser))
            }
        }
    }
    
    //MARK: sendChatRequest
    func sendChatRequest(fromUser: MPeople, forFrend: MPeople, text:String?, complition: @escaping(Result<MMessage,Error>)->Void) {
        
        let textToSend = text ?? ""
        let collectionRequestRef = db.collection(["users", forFrend.senderId, "requestChats"].joined(separator: "/"))
        let messagesRef = collectionRequestRef.document(fromUser.senderId).collection("messages")
        let messageRef = messagesRef.document("requestMessage")
        
        let message = MMessage(user: fromUser, content: textToSend, id: messagesRef.path)
        let chatMessage = MChat(friendUserName: fromUser.displayName,
                                friendUserImageString: fromUser.userImage,
                                lastMessage: message.content ?? "",
                                friendId: fromUser.senderId,
                                date: Date())
        
        do { //add chat request document for reciever user
            try collectionRequestRef.document(fromUser.senderId).setData(from: chatMessage, merge: true)
            //add message to collection messages in ChatRequest
            messageRef.setData(message.reprasentation)
            complition(.success(message))
        } catch { complition(.failure(error)) }
    }
    
    //MARK: deleteChatRequest
    func deleteChatRequest(fromUser: MChat, forUser: MPeople) {
        
        let collectionRequestRef = db.collection(["users", forUser.senderId, "requestChats"].joined(separator: "/"))
        let messagesRef = collectionRequestRef.document(fromUser.friendId).collection("messages")
        
        //delete all document in message collection for delete this collection
        deleteCollection(collection: messagesRef)
        //and delete request from userID document 
        collectionRequestRef.document(fromUser.friendId).delete()
    }
    
    //MARK: changeToActive
    func changeToActive(chat: MChat, forUser: MPeople) {
        
        let collectionRequestRef = db.collection(["users", forUser.senderId, "requestChats"].joined(separator: "/"))
        let collectionActiveRef = db.collection(["users", forUser.senderId, "activeChats"].joined(separator: "/"))
        let collectionFriendActiveRef = db.collection(["users", chat.friendId, "activeChats"].joined(separator: "/"))
        let messagesRef = collectionRequestRef.document(chat.friendId).collection("messages")
        let activeMessageRef = collectionActiveRef.document(chat.friendId).collection("messages")
        let friendActiveMessageRef = collectionFriendActiveRef.document(forUser.senderId).collection("messages")
        
        getAlldocument(type: MMessage.self, collection: messagesRef) {[weak self] allMessages in
            
            self?.deleteCollection(collection: messagesRef)
            collectionRequestRef.document(chat.friendId).delete()
            
            //add chat document to current user
            do {
                try collectionActiveRef.document(chat.friendId).setData(from: chat)
            } catch {
                fatalError("Cant convert from chat data to FirestoreData")
            }
            //add chat document to friend user
            var chatForFriend = chat
            chatForFriend.friendUserImageString = forUser.userImage
            chatForFriend.friendUserName = forUser.displayName
            chatForFriend.friendId = forUser.senderId
            do {
                try collectionFriendActiveRef.document(forUser.senderId).setData(from: chatForFriend)
            } catch {
                fatalError("Cant convert from chat data to FirestoreData")
            }
            
            //add all message to collection "messages" in  chat document
            allMessages.forEach { message in
                var currentMessageRef: DocumentReference
                //add message to current user
                currentMessageRef = activeMessageRef.addDocument(data: message.reprasentation)
                //set current path to ID message
                currentMessageRef.setData([MMessage.CodingKeys.messageId.rawValue : currentMessageRef.path], merge: true)
                //add message to friend user
                currentMessageRef = friendActiveMessageRef.addDocument(data: message.reprasentation)
                //set current path to ID message
                currentMessageRef.setData([MMessage.CodingKeys.messageId.rawValue : currentMessageRef.path], merge: true)
            }
        }
    }
    
    func sendMessage(chat: MChat,
                     currentUser: MPeople,
                     message: MMessage,
                     complition: @escaping(Result<Void, Error>)-> Void) {
        
        let refFriendChat = db.collection(["users", chat.friendId, "activeChats"].joined(separator: "/"))
        let refSenderChat = db.collection(["users", currentUser.senderId, "activeChats"].joined(separator: "/"))
        let refFriendMessage = refFriendChat.document(currentUser.senderId).collection("messages")
        let refSenderMessage = refSenderChat.document(chat.friendId).collection("messages")
        
        refFriendMessage.addDocument(data: message.reprasentation) { error in
            if let error = error {
                complition(.failure(error))
            } else {
                refSenderMessage.addDocument(data: message.reprasentation) { error in
                    if let error = error {
                        complition(.failure(error))
                    } else {
                        //set new lastMessage to activeChats
                        if let messageContent = message.content {
                            refFriendChat.document(currentUser.senderId).setData([MChat.CodingKeys.lastMessage.rawValue: messageContent,
                                                                                  MChat.CodingKeys.date.rawValue: message.sentDate],
                                                                                 merge: true)
                            refSenderChat.document(chat.friendId).setData([MChat.CodingKeys.lastMessage.rawValue: messageContent,
                                                                           MChat.CodingKeys.date.rawValue: message.sentDate],
                                                                          merge: true)
                        } else if let url = message.imageURL {
                            refFriendChat.document(currentUser.senderId).setData([MChat.CodingKeys.lastMessage.rawValue: url.absoluteString,
                                                                                  MChat.CodingKeys.date.rawValue: message.sentDate],
                                                                                 merge: true)
                            refSenderChat.document(chat.friendId).setData([MChat.CodingKeys.lastMessage.rawValue: url.absoluteString,
                                                                           MChat.CodingKeys.date.rawValue: message.sentDate],
                                                                          merge: true)
                        }
                        complition(.success(()))
                    }
                }
            }
        }  
    }
}

extension FirestoreService {
    //MARK: getAlldocument
    private func getAlldocument<T:ReprasentationModel>(type: T.Type ,collection: CollectionReference, complition:@escaping([T])-> Void) {
        var elements = [T]()
        var element: T?
        collection.getDocuments { snapshot, error in
            guard let snapshot = snapshot else { fatalError("Cant get collection snapshot")}
            
            snapshot.documents.forEach { document in
                element = T.init(documentSnap: document)
                guard let message = element else { fatalError("message is nil")}
                elements.append(message)
            }
            complition(elements)
        }
    }
    
    //MARK: deleteCollection
    //with inside document
    private func  deleteCollection(collection: CollectionReference, batchSize: Int = 100) {
        // Limit query to avoid out-of-memory errors on large collections.
        // When deleting a collection guaranteed to fit in memory, batching can be avoided entirely.
        collection.limit(to: batchSize).getDocuments { docset, error in
            // An error occurred.
            guard let docset = docset else { fatalError("Cant get collection") }
            
            let batch = collection.firestore.batch()
            docset.documents.forEach { batch.deleteDocument($0.reference) }
            
            batch.commit {_ in
                //   self.deleteCollection(collection: collection, batchSize: batchSize)
            }
        }
    }
}

