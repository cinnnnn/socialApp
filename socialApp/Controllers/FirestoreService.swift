//
//  FirestoreService.swift
//  socialApp
//
//  Created by Денис Щиголев on 07.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase
import FirebaseAuth

class FirestoreService {
    
    static let shared = FirestoreService()
    
    private init() {}
    
    private let db = Firestore.firestore()
    
    private var usersReference: CollectionReference {
        db.collection("users")
    }
    
    //MARK: - saveProfile
    
    func saveProfile(id: String,
                     email: String,
                     username: String?,
                     avatarImage: UIImage?,
                     advert: String?,
                     search: String,
                     sex: String,
                     complition: @escaping (Result<MPeople, Error>) -> Void){
        
       
        
        guard let avatar = avatarImage else { fatalError("cant get userProfile image") }
        
        let isFilled = Validators.shared.isFilledSetProfile(userName: username, advert: advert)
        
        guard isFilled.isFilled else {
            complition(.failure(AuthError.notFilled))
            return
        }
        
        
        var user = MPeople(userName: isFilled.userName,
                           advert: isFilled.advert,
                           userImage: "gs://socialapp-aacc9.appspot.com/avatars/avatar@3x.png",
                           search: search,
                           mail: email,
                           sex: sex,
                           id: id)
        
        //if user choose photo, than upload new photo to Storage
        if  avatarImage != #imageLiteral(resourceName: "avatar")  {
            StorageService.shared.uploadImage(image: avatar) { result in
                switch result {
                    
                case .success(let url):
                    user.userImage = url.absoluteString
                case .failure(_):
                    fatalError("Cant upload image")
                }
            }
        }
        
        //save user to FireStore
        usersReference.document(user.id).setData(user.representation) { error in
            
            if let error = error {
                complition(.failure(error))
            } else {
                complition(.success(user))
            }
            
        }
        
    }
    
    //MARK: - getUserData
    
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
                    complition(.failure(UserError.incorrectSetProfile))
                }
                
            }
        
       
        }
    }
    

