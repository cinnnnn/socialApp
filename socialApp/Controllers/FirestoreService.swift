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
                    self?.usersReference.document(user.uid).setData(["userImage" : userImageString], merge: true, completion: { error in
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
        usersReference.document(id).setData([MPeople.CodingKeys.id.rawValue : id,
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
        usersReference.document(user.uid).setData([MPeople.CodingKeys.userName.rawValue : userName,
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
    func getUserData(user: User, complition: @escaping (Result<MPeople,Error>) -> Void) {
        
        let documentReference = usersReference.document(user.uid)
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
    
    func sendChatRequest(fromUser: MPeople, forFrend: MPeople, text:String?, complition: @escaping(Result<MMessage,Error>)->Void) {
        
        let textToSend = text ?? ""
        let collectionRef = db.collection(["users", forFrend.id, "chatRequest"].joined(separator: "/"))
        let messagesRef = collectionRef.document(fromUser.id).collection("messages")
        let messageRef = messagesRef.document("requestMessage")
        
        let message = MMessage(user: fromUser, content: textToSend, id: messagesRef.path)
        let chatMessage = MChat(friendUserName: fromUser.userName,
                                friendUserImageString: fromUser.userImage,
                                lastMessage: message.content,
                                friendId: fromUser.id,
                                date: Date())
        
        do { //add chat request document for reciever user
            try collectionRef.document(fromUser.id).setData(from: chatMessage, merge: true)
            do {//add message to collection messages in ChatRequest
                try messageRef.setData(from: message)
                complition(.success(message))
            } catch {  complition(.failure(error)) }
        } catch { complition(.failure(error)) }
    }
}


