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
    
    private let db = Firestore.firestore()
    private var usersReference: CollectionReference {
        db.collection(MFirestorCollection.users.rawValue)
    }
    
    private init() {}
    
    //MARK:  saveBaseProfile
    func saveBaseProfile(id: String,
                         email: String,
                         authType: MAuthType,
                         complition: @escaping (Result<String, Error>) -> Void){
        
        let authTypeString = authType.rawValue
        //save base user info to cloud FireStore
        usersReference.document(id).setData([MPeople.CodingKeys.senderId.rawValue : id,
                                             MPeople.CodingKeys.mail.rawValue: email,
                                             MPeople.CodingKeys.authType.rawValue: authTypeString],
                                            merge: true,
                                            completion: { (error) in
                                                if let error = error {
                                                    fatalError(error.localizedDescription)
                                                } else {
                                                    complition(.success(id))
                                                }
                                            })
    }
    
    //MARK:  saveFirstSetupDateOfBirth
    func saveFirstSetupDateOfBirth(id: String,
                                   dateOfBirth: Date,
                                   complition: @escaping (Result<Void, Error>) -> Void){
        usersReference.document(id).setData([MPeople.CodingKeys.dateOfBirth.rawValue: dateOfBirth],
                                            merge: true,
                                            completion: { error in
                                                if let error = error {
                                                    complition(.failure(error))
                                                } else {
                                                    complition(.success(()))
                                                }
                                            })
    }
    //MARK:  saveFirstSetupNameGender
    func saveFirstSetupNameGender(id: String,
                                  userName: String,
                                  gender: String,
                                  lookingFor: String,
                                  sexuality: String,
                                  complition: @escaping (Result<Void, Error>) -> Void) {
        
        let searchSettings = [MSearchSettings.distance.rawValue : MSearchSettings.distance.defaultValue,
                              MSearchSettings.minRange.rawValue : MSearchSettings.minRange.defaultValue,
                              MSearchSettings.maxRange.rawValue : MSearchSettings.maxRange.defaultValue,
                              MSearchSettings.currentLocation.rawValue : MSearchSettings.currentLocation.defaultValue]
        
        usersReference.document(id).setData([MPeople.CodingKeys.displayName.rawValue : userName,
                                             MPeople.CodingKeys.gender.rawValue : gender,
                                             MPeople.CodingKeys.lookingFor.rawValue : lookingFor,
                                             MPeople.CodingKeys.sexuality.rawValue : sexuality,
                                             MPeople.CodingKeys.isActive.rawValue: true,
                                             MPeople.CodingKeys.isAdmin.rawValue: false,
                                             MPeople.CodingKeys.isBlocked.rawValue: false,
                                             MPeople.CodingKeys.goldMember.rawValue: false,
                                             MPeople.CodingKeys.searchSettings.rawValue: searchSettings],
                                            merge: true,
                                            completion: { (error) in
                                                if let error = error {
                                                    complition(.failure(error))
                                                } else {
                                                    complition(.success(()))
                                                }
                                            })
    }
    
    //MARK:  saveFirstSetupAdvert
    func saveAdvert(id: String,
                    advert: String,
                    complition: @escaping (Result<Void, Error>) -> Void){
        usersReference.document(id).setData([MPeople.CodingKeys.advert.rawValue: advert],
                                            merge: true,
                                            completion: { error in
                                                if let error = error {
                                                    complition(.failure(error))
                                                } else {
                                                    complition(.success(()))
                                                }
                                            })
    }
    
    //MARK:  saveProfileAfterEdit
    func saveProfileAfterEdit(id: String,
                              name: String,
                              advert: String,
                              gender: String,
                              sexuality: String,
                              complition: @escaping (Result<Void,Error>) -> Void) {
        usersReference.document(id).setData([MPeople.CodingKeys.displayName.rawValue : name,
                                             MPeople.CodingKeys.advert.rawValue : advert,
                                             MPeople.CodingKeys.gender.rawValue : gender,
                                             MPeople.CodingKeys.sexuality.rawValue : sexuality],
                                            merge: true) { error in
            if let error = error {
                complition(.failure(error))
            } else {
                //edit current user from UserDefaults for save request to server
                if var people = UserDefaultsService.shared.getMpeople() {
                    people.displayName = name
                    people.advert = advert
                    people.gender = gender
                    people.sexuality = sexuality
                    UserDefaultsService.shared.saveMpeople(people: people)
                }
                complition(.success(()))
            }
        }
    }
    
    //MARK:  saveSearchSettings
    func saveSearchSettings(id: String,
                            distance: Int,
                            minRange: Int,
                            maxRange: Int,
                            currentLocation: Int,
                            lookingFor: String,
                            complition: @escaping (Result<MPeople, Error>) -> Void) {
        
        let searchSettings = [MSearchSettings.distance.rawValue : distance,
                              MSearchSettings.minRange.rawValue : minRange,
                              MSearchSettings.maxRange.rawValue : maxRange,
                              MSearchSettings.currentLocation.rawValue : currentLocation]
        
        usersReference.document(id).setData([MPeople.CodingKeys.lookingFor.rawValue : lookingFor,
                                             MPeople.CodingKeys.searchSettings.rawValue: searchSettings],
                                            merge: true,
                                            completion: { (error) in
                                                if let error = error {
                                                    complition(.failure(error))
                                                } else {
                                                    //save people to UserDefaults for save request to server
                                                    if var people = UserDefaultsService.shared.getMpeople() {
                                                        people.lookingFor = lookingFor
                                                        people.searchSettings = searchSettings
                                                        UserDefaultsService.shared.saveMpeople(people: people)
                                                        complition(.success(people))
                                                    } else {
                                                        complition(.failure(UserDefaultsError.cantGetData))
                                                    }
                                                }
                                            })
    }
    
    
    //MARK: saveLocation
    func saveLocation(userID: String, longitude: Double, latitude: Double, complition: @escaping (Result<[String:Double],Error>) -> Void) {
        usersReference.document(userID).setData([MPeople.CodingKeys.location.rawValue : [MLocation.longitude.rawValue:longitude,
                                                                                         MLocation.latitude.rawValue:latitude]],
                                                merge: true) { error in
            if let error = error {
                complition(.failure(error))
            } else {
                complition(.success([MLocation.longitude.rawValue:longitude,
                                     MLocation.latitude.rawValue:latitude]))
            }
        }
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
    
    //MARK: getUserCollection
    func getUserCollection(userID: String, collection: MFirestorCollection, complition: @escaping(Result<[MChat], Error>)->Void) {
        
        let reference = usersReference.document(userID).collection(collection.rawValue)
        var chats: [MChat] = []
        reference.getDocuments { snapshot, error in
            if let error = error {
                complition(.failure(error))
            }
            guard let snapshot = snapshot else {
                complition(.failure(FirestoreError.snapshotNotExist))
                return
            }
            snapshot.documents.forEach({ queryDocumentSnapshot in
                if let chat = MChat(documentSnap: queryDocumentSnapshot) {
                    chats.append(chat)
                }
            })
            complition(.success(chats))
        }
    }
    
    
    //MARK: sendChatRequest
    func sendChatRequest(fromUser: MPeople, forFrend: MPeople, text:String?, complition: @escaping(Result<MMessage,Error>)->Void) {
        
        let textToSend = text ?? MLabels.requestMessage.rawValue
        let collectionRequestRef = db.collection([MFirestorCollection.users.rawValue, forFrend.senderId, MFirestorCollection.acceptChats.rawValue].joined(separator: "/"))
        let messagesRef = collectionRequestRef.document(fromUser.senderId).collection(MFirestorCollection.messages.rawValue)
        let messageRef = messagesRef.document(MFirestorCollection.requestMessage.rawValue)
        
        let sender = MSender(senderId: fromUser.senderId, displayName: fromUser.displayName)
        let message = MMessage(user: sender, content: textToSend, id: messagesRef.path)
        let chatMessage = MChat(friendUserName: fromUser.displayName,
                                friendUserImageString: fromUser.userImage,
                                lastMessage: textToSend,
                                isNewChat: false,
                                friendId: fromUser.senderId,
                                unreadChatMessageCount: 0,
                                friendIsWantStopTimer: false,
                                currentUserIsWantStopTimer: false,
                                timerOfLifeIsStoped: false,
                                createChatDate: Date(),
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
        
        let collectionRequestRef = db.collection([MFirestorCollection.users.rawValue, forUser.senderId, MFirestorCollection.requestsChats.rawValue].joined(separator: "/"))
        let messagesRef = collectionRequestRef.document(fromUser.friendId).collection(MFirestorCollection.messages.rawValue)
        
        //delete all document in message collection for delete this collection
        deleteCollection(collection: messagesRef)
        //and delete request from userID document 
        collectionRequestRef.document(fromUser.friendId).delete()
    }
    
    //MARK: likePeople
    func likePeople(currentPeople: MPeople, likePeople: MPeople,message: String = "", requestChats: [MChat], complition: @escaping(Result<MChat,Error>)->Void) {
        
        let collectionLikeUserRequestRef = db.collection([MFirestorCollection.users.rawValue, likePeople.senderId, MFirestorCollection.requestsChats.rawValue].joined(separator: "/"))
        let collectionLikeUserAcceptChatRef = db.collection([MFirestorCollection.users.rawValue, likePeople.senderId, MFirestorCollection.acceptChats.rawValue].joined(separator: "/"))
        let collectionLikeUserLikeRef = db.collection([MFirestorCollection.users.rawValue, likePeople.senderId, MFirestorCollection.likePeople.rawValue].joined(separator: "/"))
        let collectionCurrentRequestRef = db.collection([MFirestorCollection.users.rawValue, currentPeople.senderId, MFirestorCollection.requestsChats.rawValue].joined(separator: "/"))
        let collectionCurrentLikeRef = db.collection([MFirestorCollection.users.rawValue, currentPeople.senderId, MFirestorCollection.likePeople.rawValue].joined(separator: "/"))
        let collectionCurrentAcceptChatRef = db.collection([MFirestorCollection.users.rawValue, currentPeople.senderId, MFirestorCollection.acceptChats.rawValue].joined(separator: "/"))
        
        let likeUserMessagesRef = collectionLikeUserAcceptChatRef.document(currentPeople.senderId).collection(MFirestorCollection.messages.rawValue)
        let likeUserMessageRef = likeUserMessagesRef.document(MFirestorCollection.requestMessage.rawValue)
        let currentUserMessagesRef = collectionCurrentAcceptChatRef.document(currentPeople.senderId).collection(MFirestorCollection.messages.rawValue)
        let currentUserMessageRef = currentUserMessagesRef.document(MFirestorCollection.requestMessage.rawValue)
        
        var requestChat = MChat(friendUserName: currentPeople.displayName,
                                friendUserImageString: currentPeople.userImage,
                                lastMessage: message,
                                isNewChat: true,
                                friendId: currentPeople.senderId,
                                unreadChatMessageCount: 0,
                                friendIsWantStopTimer: false,
                                currentUserIsWantStopTimer: false,
                                timerOfLifeIsStoped: false,
                                createChatDate: Date(),
                                date: Date())
        var likeChat = MChat(friendUserName: likePeople.displayName,
                             friendUserImageString: likePeople.userImage,
                             lastMessage: message,
                             isNewChat: true,
                             friendId: likePeople.senderId,
                             unreadChatMessageCount: 0,
                             friendIsWantStopTimer: false,
                             currentUserIsWantStopTimer: false,
                             timerOfLifeIsStoped: false,
                             createChatDate: Date(),
                             date: Date())
        
        //if like people contains in current user request chat than add to newChat and delete in request
        let requestChatFromLikeUser = requestChats.filter { requestChat -> Bool in
            requestChat.containsID(ID: likePeople.senderId)
        }
        //if have requst chat from like user
        if let chat = requestChatFromLikeUser.first {
            //delete from request
            collectionCurrentRequestRef.document(likePeople.senderId).delete()
            //delete from like in like user collection
            collectionLikeUserLikeRef.document(currentPeople.senderId).delete()
            let sender = MSender(senderId: currentPeople.senderId, displayName: currentPeople.displayName)
            var requestMessage = MMessage(user: sender,
                                          content: chat.lastMessage,
                                          id: currentUserMessageRef.path)
            
            do { //add to acceptChat to current user
                //if with first message, create chat and message in collection
                if !chat.lastMessage.isEmpty {
                    likeChat.unreadChatMessageCount = 1
                    try collectionCurrentAcceptChatRef.document(likePeople.senderId).setData(from: likeChat)
                    currentUserMessageRef.setData(requestMessage.reprasentation)
                } else {
                    try collectionCurrentAcceptChatRef.document(likePeople.senderId).setData(from: likeChat)
                }
            } catch { complition(.failure(error))}
            
            do { //add to acceptChat to like user
                if !chat.lastMessage.isEmpty {
                    requestChat.unreadChatMessageCount = 1
                    try collectionLikeUserAcceptChatRef.document(currentPeople.senderId).setData(from: requestChat)
                    //change message id to likeUser path
                    requestMessage.messageId = likeUserMessageRef.path
                    //if with first message, create message in collection
                    likeUserMessageRef.setData(requestMessage.reprasentation)
                } else {
                    try collectionLikeUserAcceptChatRef.document(currentPeople.senderId).setData(from: requestChat)
                }
            } catch { complition(.failure(error))}
            complition(.success(likeChat))
            //if don't have request from like user
        } else {
            do { //add chat request for like user
                try collectionLikeUserRequestRef.document(currentPeople.senderId).setData(from: requestChat, merge: true)
                //add chat to like collection current user
                try collectionCurrentLikeRef.document(likePeople.senderId).setData(from:likeChat)
                complition(.success(likeChat))
            } catch { complition(.failure(error)) }
        }
    }
    
    
    //MARK: dislikePeople
    func dislikePeople(currentPeople: MPeople, dislikeForPeople: MPeople, requestChats: [MChat], complition: @escaping(Result<MChat,Error>)->Void) {
        let collectionCurrentUserDislikeRef = usersReference.document(currentPeople.senderId).collection(MFirestorCollection.dislikePeople.rawValue)
        let collectionCurrentRequestRef = db.collection([MFirestorCollection.users.rawValue, currentPeople.senderId, MFirestorCollection.requestsChats.rawValue].joined(separator: "/"))
        let collectionDislikeUserLikeRef = db.collection([MFirestorCollection.users.rawValue, dislikeForPeople.senderId, MFirestorCollection.likePeople.rawValue].joined(separator: "/"))
        
        let dislikeChat = MChat(friendUserName: dislikeForPeople.displayName,
                                friendUserImageString: dislikeForPeople.userImage,
                                lastMessage: "",
                                isNewChat: true,
                                friendId: dislikeForPeople.senderId,
                                unreadChatMessageCount: 0,
                                friendIsWantStopTimer: false,
                                currentUserIsWantStopTimer: false,
                                timerOfLifeIsStoped: false,
                                createChatDate: Date(),
                                date: Date())
        //if dislike people contains in current user request chat, than delete his request
        let requestChatFromLikeUser = requestChats.filter { requestChat -> Bool in
            requestChat.containsID(ID: dislikeForPeople.senderId)
        }
        //if have requst chat from dislike user
        if let _ = requestChatFromLikeUser.first {
            //delete from request
            collectionCurrentRequestRef.document(dislikeForPeople.senderId).delete()
            //delete from like in dislike user collection
            collectionDislikeUserLikeRef.document(currentPeople.senderId).delete()
        }
        do {
            try collectionCurrentUserDislikeRef.document(dislikeForPeople.senderId).setData(from: dislikeChat)
            complition(.success(dislikeChat))
        } catch { complition(.failure(error))}
    }
    
    //MARK: readAllMessageInChat
    func readAllMessageInChat(userID: String, chat: MChat, complition: @escaping(Result<(),Error>) -> Void) {
        let refChat = db.collection([MFirestorCollection.users.rawValue,
                                     userID,
                                     MFirestorCollection.acceptChats.rawValue].joined(separator: "/"))
        refChat.document(chat.friendId).updateData([ MChat.CodingKeys.unreadChatMessageCount.rawValue : 0]) { error in
            if let error = error {
                complition(.failure(error))
            } else {
                complition(.success(()))
            }
        }
    }
    
    //MARK: deactivateChatTimer
    func deactivateChatTimer(userID: String, chat: MChat, complition: @escaping (Result<(),Error>)-> Void) {
        let refCurrentChatCollection = db.collection([MFirestorCollection.users.rawValue,
                                                      userID,
                                                      MFirestorCollection.acceptChats.rawValue].joined(separator: "/"))
        let refFriendChatCollection = db.collection([MFirestorCollection.users.rawValue,
                                                     chat.friendId,
                                                     MFirestorCollection.acceptChats.rawValue].joined(separator: "/"))
        let currentChatDocument = refCurrentChatCollection.document(chat.friendId)
        let friendChatDocument = refFriendChatCollection.document(userID)
        
        if chat.friendIsWantStopTimer {
            //if friend already want to stop chat timer, set timer is stoped to friend chat
            friendChatDocument.updateData([MChat.CodingKeys.friendIsWantStopTimer.rawValue : true,
                                           MChat.CodingKeys.timerOfLifeIsStoped.rawValue: true]) { error in
                if let error = error  {
                    complition(.failure(error))
                } else {
                    //set timer is stoped to current chat
                    currentChatDocument.updateData([MChat.CodingKeys.friendIsWantStopTimer.rawValue : true,
                                                    MChat.CodingKeys.timerOfLifeIsStoped.rawValue: true,
                                                    MChat.CodingKeys.currentUserIsWantStopTimer.rawValue: true]) { error in
                        if let error = error  {
                            complition(.failure(error))
                        } else {
                            complition(.success(()))
                        }
                    }
                }
            }
            
        } else {
            //if friend doesn't want stop timer, set to friend's chat, that you want to stop timer
            friendChatDocument.updateData([MChat.CodingKeys.friendIsWantStopTimer.rawValue : true]) { error in
                if let error = error {
                    complition(.failure(error))
                } else {
                    //set current user want stop timer
                    currentChatDocument.updateData([MChat.CodingKeys.currentUserIsWantStopTimer.rawValue: true]) { error in
                        guard error == nil else {
                            complition(.failure(error!))
                            return
                        }
                        complition(.success(()))
                    }
                }
            }
        }
    }
    
    //MARK: sendMessage
    func sendMessage(chat: MChat,
                     currentUser: MPeople,
                     message: MMessage,
                     complition: @escaping(Result<Void, Error>)-> Void) {
        let refFriendChat = db.collection([MFirestorCollection.users.rawValue,
                                           chat.friendId,
                                           MFirestorCollection.acceptChats.rawValue].joined(separator: "/"))
        let refSenderChat = db.collection([MFirestorCollection.users.rawValue,
                                           currentUser.senderId,
                                           MFirestorCollection.acceptChats.rawValue].joined(separator: "/"))
        
        let refFriendMessage = refFriendChat.document(currentUser.senderId).collection(MFirestorCollection.messages.rawValue)
        let refSenderMessage = refSenderChat.document(chat.friendId).collection(MFirestorCollection.messages.rawValue)
        
        refFriendMessage.addDocument(data: message.reprasentation) { error in
            if let error = error {
                complition(.failure(error))
            } else {
                refSenderMessage.addDocument(data: message.reprasentation) { error in
                    if let error = error {
                        complition(.failure(error))
                    } else {
                        //set new lastMessage to activeChats, set to active chat and increment unread message
                        if let messageContent = message.content {
                            refFriendChat.document(currentUser.senderId).updateData([MChat.CodingKeys.lastMessage.rawValue: messageContent,
                                                                                     MChat.CodingKeys.date.rawValue: message.sentDate,
                                                                                     MChat.CodingKeys.isNewChat.rawValue: false,
                                                                                     MChat.CodingKeys.unreadChatMessageCount.rawValue : FieldValue.increment(Int64(1))]) { error in
                                if let error = error {
                                    complition(.failure(error))
                                }
                            }
                            refSenderChat.document(chat.friendId).updateData([MChat.CodingKeys.lastMessage.rawValue: messageContent,
                                                                              MChat.CodingKeys.date.rawValue: message.sentDate,
                                                                              MChat.CodingKeys.isNewChat.rawValue: false]) { error in
                                if let error = error {
                                    complition(.failure(error))
                                } else {
                                    complition(.success(()))
                                }
                            }
                        } else if let _ = message.imageURL {
                            refFriendChat.document(currentUser.senderId).updateData([MChat.CodingKeys.lastMessage.rawValue: "Фото 📷",
                                                                                     MChat.CodingKeys.date.rawValue: message.sentDate,
                                                                                     MChat.CodingKeys.isNewChat.rawValue: false,
                                                                                     MChat.CodingKeys.unreadChatMessageCount.rawValue : FieldValue.increment(Int64(1))]) { error in
                                if let error = error {
                                    complition(.failure(error))
                                }
                            }
                            refSenderChat.document(chat.friendId).updateData([MChat.CodingKeys.lastMessage.rawValue: "Фото 📷",
                                                                              MChat.CodingKeys.date.rawValue: message.sentDate,
                                                                              MChat.CodingKeys.isNewChat.rawValue: false]) { error in
                                if let error = error {
                                    complition(.failure(error))
                                } else {
                                    complition(.success(()))
                                }
                            }
                        }
                        
                    }
                }
            }
        }  
    }
}

//MARK: - WORK WITH PROFILE
extension FirestoreService {
    
    
    //MARK: deleteAllChats
    func deleteAllChats(forPeopleID: String, complition: @escaping ()-> Void) {
        
        //delete acceptChats
        let refChats = db.collection([MFirestorCollection.users.rawValue, forPeopleID, MFirestorCollection.acceptChats.rawValue].joined(separator: "/"))
        
        //get all acceptChats, for delete messages collection
        getAlldocument(type: MChat.self, collection: refChats) {[weak self] chats in
            chats.forEach { chat in
                
                //delete all message in current chat
                let refMessages = refChats.document(chat.friendId).collection(MFirestorCollection.messages.rawValue)
                self?.deleteCollection(collection: refMessages)
                
                //friend chat
                guard let refFriendChat = self?.db.collection([MFirestorCollection.users.rawValue, chat.friendId, MFirestorCollection.acceptChats.rawValue].joined(separator: "/")) else { return }
                
                //delete all messages in friend chat
                let refFriendChatMessages = refFriendChat.document(forPeopleID).collection(MFirestorCollection.messages.rawValue)
                self?.deleteCollection(collection: refFriendChatMessages)
                
                //delete chat document from friend
                refFriendChat.document(forPeopleID).delete()
                
                //delete chat document from current user
                refChats.document(chat.friendId).delete()
                
                //delete chat images for this chat
                StorageService.shared.deleteChatImages(currentUserID: forPeopleID, friendUserID: chat.friendId)
            }
            complition()
        }
    }
    
    //MARK: deleteChat
    func deleteChat(currentUserID: String, friendID: String) {
        
        //delete acceptChats
        let refChat = db.document([MFirestorCollection.users.rawValue,
                                   currentUserID,
                                   MFirestorCollection.acceptChats.rawValue,
                                   friendID].joined(separator: "/"))
        let friendChat = db.document([MFirestorCollection.users.rawValue,
                                      friendID,
                                      MFirestorCollection.acceptChats.rawValue,
                                      currentUserID].joined(separator: "/"))
        
        let refMessageCollection = refChat.collection(MFirestorCollection.messages.rawValue)
        let refFriendMessageCollection = friendChat.collection(MFirestorCollection.messages.rawValue)
        //delete all messages from current and friend user
        deleteCollection(collection: refMessageCollection)
        deleteCollection(collection: refFriendMessageCollection)
        
        //delete chat document from current and friend user
        refChat.delete()
        friendChat.delete()
        
        //delete chat images
        StorageService.shared.deleteChatImages(currentUserID: currentUserID, friendUserID: friendID)
    }
    
    //MARK: delte input request
    func deleteInputRequest(currentUserID: String, complition: @escaping ()-> Void) {
        let refCurrentRequestChat = db.collection([MFirestorCollection.users.rawValue,
                                                   currentUserID,
                                                   MFirestorCollection.requestsChats.rawValue].joined(separator: "/"))
        
        getAlldocument(type: MChat.self, collection: refCurrentRequestChat) {[weak self] requestChats in
            requestChats.forEach { chat in
                //delete request chat for current user
                refCurrentRequestChat.document(chat.friendId).delete()
                //delete like chat for friend collection
                let refFriendLike = self?.db.collection([MFirestorCollection.users.rawValue,
                                                         chat.friendId,
                                                         MFirestorCollection.likePeople.rawValue].joined(separator: "/"))
                
                refFriendLike?.document(currentUserID).delete()
            }
            complition()
        }
    }
    
    //MARK: delte output like
    func deleteOutputLike(currentUserID: String, complition: @escaping ()-> Void) {
        let refCurrentLikeChat = db.collection([MFirestorCollection.users.rawValue,
                                                currentUserID,
                                                MFirestorCollection.likePeople.rawValue].joined(separator: "/"))
        
        getAlldocument(type: MChat.self, collection: refCurrentLikeChat) {[weak self] likeChats in
            likeChats.forEach { chat in
                //delete output like chat for current user
                refCurrentLikeChat.document(chat.friendId).delete()
                //delete request chat for friend collection
                let refFriendRequest = self?.db.collection([MFirestorCollection.users.rawValue,
                                                            chat.friendId,
                                                            MFirestorCollection.requestsChats.rawValue].joined(separator: "/"))
                
                refFriendRequest?.document(currentUserID).delete()
            }
            complition()
        }
    }
    
    //MARK: delete all dislike
    func deleteAllDislikes(userID: String, complition: @escaping ()-> Void) {
        
        let refCurrentRequestChat = db.collection([MFirestorCollection.users.rawValue,
                                                   userID,
                                                   MFirestorCollection.dislikePeople.rawValue].joined(separator: "/"))
        getAlldocument(type: MChat.self, collection: refCurrentRequestChat) { dislikeChats in
            dislikeChats.forEach { dislikeChat in
                refCurrentRequestChat.document(dislikeChat.friendId).delete()
            }
            complition()
        }
    }
    
    //MARK: delete profile document
    func deleteProfileDocument(userID: String, complition: @escaping ()-> Void) {
        let refCurrentUser = db.collection(MFirestorCollection.users.rawValue).document(userID)
        refCurrentUser.delete()
        //delete profile images
        StorageService.shared.deleteProfileImages(userID: userID)
        complition()
    }
    
    
    //MARK: unMatch
    func unMatch(currentUser: MPeople, chat: MChat, complition:@escaping(Result<MChat,Error>)->Void) {
        //delete all chat and messages
        deleteChat(currentUserID: currentUser.senderId, friendID: chat.friendId)
        //add dislike to current and friend collection
        let refCurrentDislike = db.collection([MFirestorCollection.users.rawValue, currentUser.senderId, MFirestorCollection.dislikePeople.rawValue].joined(separator: "/"))
        let refFriendDislike = db.collection([MFirestorCollection.users.rawValue, chat.friendId, MFirestorCollection.dislikePeople.rawValue].joined(separator: "/"))
        
        var dislikeChat = MChat(friendUserName: chat.friendUserName,
                                friendUserImageString: chat.friendUserImageString,
                                lastMessage: "",
                                isNewChat: true,
                                friendId: chat.friendId,
                                unreadChatMessageCount: 0,
                                friendIsWantStopTimer: false,
                                currentUserIsWantStopTimer: false,
                                timerOfLifeIsStoped: false,
                                createChatDate: Date(),
                                date: Date())
        
        do {
            try refCurrentDislike.document(chat.friendId).setData(from: dislikeChat)
            //change info in chat and write to friend dislike collection
            dislikeChat.friendUserName = currentUser.displayName
            dislikeChat.friendUserImageString = currentUser.userImage
            dislikeChat.friendId = currentUser.senderId
            try refFriendDislike.document(currentUser.senderId).setData(from: dislikeChat)
            complition(.success(dislikeChat))
        } catch { complition(.failure(error))}
    }
    
    //MARK: delete all profile data
    func deleteAllProfileData(userID: String, complition: @escaping () -> Void) {
        deleteAllChats(forPeopleID: userID) { [weak self] in
            //delete input requests and like chats for people who send a request
            self?.deleteInputRequest(currentUserID: userID, complition: {
                //delete output likes and request who got a like
                self?.deleteOutputLike(currentUserID: userID, complition: {
                    //delete all dislikes users
                    self?.deleteAllDislikes(userID: userID, complition: {
                        //delete profile document
                        self?.deleteProfileDocument(userID: userID, complition: {
                            //delete current user Auth data
                            AuthService.shared.deleteUser { result in
                                switch result {
                                
                                case .success(let isDelete):
                                    if isDelete {
                                        complition()
                                    }
                                case .failure(let error):
                                    fatalError(error.localizedDescription)
                                }
                            }
                        })
                    })
                })
            })
        }
    }
}

//MARK: - WORK WITH IMAGE
extension FirestoreService {
    
    //MARK:  saveDefaultImage
    func saveDefaultImage(id: String, defaultImageString: String, complition: @escaping (Result<Void, Error>) -> Void) {
        usersReference.document(id).setData([MPeople.CodingKeys.userImage.rawValue : defaultImageString],
                                            merge: true,
                                            completion: { (error) in
                                                if let error = error {
                                                    complition(.failure(error))
                                                } else {
                                                    complition(.success(()))
                                                }
                                            })
    }
    
    //MARK:  saveAvatar
    func saveAvatar(image: UIImage?, id: String, complition: @escaping (Result<String, Error>) -> Void) {
        
        guard let avatar = image else { fatalError("cant get userProfile image") }
        //if user choose photo, than upload new photo to Storage
        if  image != #imageLiteral(resourceName: "avatar")  {
            StorageService.shared.uploadImage(image: avatar) {[weak self] result in
                switch result {
                
                case .success(let url):
                    let userImageString = url.absoluteString
                    //save user to FireStore
                    self?.usersReference.document(id).setData([MPeople.CodingKeys.userImage.rawValue : userImageString], merge: true, completion: { error in
                        if let error = error {
                            complition(.failure(error))
                        } else {
                            //edit current user from UserDefaults for save request to server
                            if var people = UserDefaultsService.shared.getMpeople() {
                                people.userImage = userImageString
                                UserDefaultsService.shared.saveMpeople(people: people)
                            }
                            complition(.success(userImageString))
                        }
                    })
                case .failure(_):
                    fatalError("Cant upload Image")
                }
            }
        }
    }
    
    //MARK: updateAvatar
    func updateAvatar(imageURLString: String, currentAvatarURL: String, id: String, complition:@escaping(Result<String, Error>) -> Void) {
        
        //set current image to profile image
        usersReference.document(id).setData(
            [MPeople.CodingKeys.userImage.rawValue : imageURLString],
            merge: true,
            completion: {[weak self] error in
                
                if let error = error {
                    complition(.failure(error))
                } else {
                    //edit current user from UserDefaults for save request to server
                    if var people = UserDefaultsService.shared.getMpeople() {
                        people.userImage = imageURLString
                        UserDefaultsService.shared.saveMpeople(people: people)
                    }
                    //if success, delete current image from gallery, but save in storage, for use in profileImage
                    self?.deleteFromGallery(imageURLString: imageURLString, deleteInStorage: false, id: id) { result in
                        switch result {
                        
                        case .success(_):
                            //if delete is success, append old profile image to gallery
                            self?.saveImageToGallery(image: nil, uploadedImageLink: currentAvatarURL, id: id) { result in
                                switch result {
                                
                                case .success(_):
                                    complition(.success(imageURLString))
                                case .failure(let error):
                                    complition(.failure(error))
                                }
                            }
                        case .failure(_):
                            break
                        }
                    }
                }
            }
        )
    }
    
    //MARK:  saveImageToGallery
    func saveImageToGallery(image: UIImage?, uploadedImageLink: String? = nil, id: String, complition: @escaping (Result<String, Error>) -> Void) {
        
        //if new image, than upload to Storage
        if uploadedImageLink == nil {
            guard let image = image else { return }
            StorageService.shared.uploadImage(image: image) {[weak self] result in
                switch result {
                
                case .success(let url):
                    let userImageString = url.absoluteString
                    //save user to FireStore
                    self?.usersReference.document(id).setData([MPeople.CodingKeys.gallery.rawValue : FieldValue.arrayUnion([userImageString])],
                                                              merge: true,
                                                              completion: { error in
                                                                if let error = error {
                                                                    complition(.failure(error))
                                                                } else {
                                                                    //edit current user from UserDefaults for save request to server
                                                                    if var people = UserDefaultsService.shared.getMpeople() {
                                                                        people.gallery.append(userImageString)
                                                                        UserDefaultsService.shared.saveMpeople(people: people)
                                                                    }
                                                                    complition(.success(userImageString))
                                                                }
                                                              })
                case .failure(_):
                    fatalError("Cant upload Image")
                }
            }
        } else {
            //if image already upload, append link to gallery array
            guard let imageLink = uploadedImageLink else { return }
            usersReference.document(id).setData([MPeople.CodingKeys.gallery.rawValue : FieldValue.arrayUnion([imageLink])],
                                                merge: true,
                                                completion: { error in
                                                    if let error = error {
                                                        complition(.failure(error))
                                                    } else {
                                                        //edit current user from UserDefaults for save request to server
                                                        if var people = UserDefaultsService.shared.getMpeople() {
                                                            people.gallery.append(imageLink)
                                                            UserDefaultsService.shared.saveMpeople(people: people)
                                                        }
                                                        complition(.success(imageLink))
                                                    }
                                                })
        }
    }
    
    //MARK: deleteFromGallery
    func deleteFromGallery(imageURLString: String, deleteInStorage:Bool = true,  id: String, complition:@escaping(Result<String, Error>) -> Void) {
        
        //delete image from array in Firestore
        usersReference.document(id).setData([MPeople.CodingKeys.gallery.rawValue : FieldValue.arrayRemove([imageURLString])],
                                            merge: true,
                                            completion: { error in
                                                if let error = error {
                                                    complition(.failure(error))
                                                } else {
                                                    //edit current user from UserDefaults for save request to server
                                                    if var people = UserDefaultsService.shared.getMpeople() {
                                                        guard let indexOfImage = people.gallery.firstIndex(of: imageURLString) else { return }
                                                        people.gallery.remove(at: indexOfImage)
                                                        UserDefaultsService.shared.saveMpeople(people: people)
                                                    }
                                                    if deleteInStorage {
                                                        //delete image from storage
                                                        StorageService.shared.deleteImage(link: imageURLString) { result in
                                                            switch result {
                                                            
                                                            case .success(_):
                                                                complition(.success(imageURLString))
                                                            case .failure(let error):
                                                                complition(.failure(error))
                                                            }
                                                        }
                                                    } else {
                                                        complition(.success(imageURLString))
                                                    }
                                                }
                                            })
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
                element = T(documentSnap: document)
                guard let elementTType = element else { fatalError("Cant convert doc to T type")}
                elements.append(elementTType)
            }
            complition(elements)
        }
    }
    
    //MARK: deleteCollection
    //with inside document
    private func  deleteCollection(collection: CollectionReference, batchSize: Int = 500) {
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
