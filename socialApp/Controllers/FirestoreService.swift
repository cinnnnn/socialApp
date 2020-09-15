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
        
        var mPeople = MPeople(userName: isFilled.userName,
                              advert: isFilled.advert,
                              userImage: "",
                              search: search,
                              mail: email,
                              sex: sex,
                              id: id)
        
        //if user choose photo, than upload new photo to Storage
        if  avatarImage != #imageLiteral(resourceName: "avatar")  {
            StorageService.shared.uploadImage(image: avatar) {[weak self] result in
                switch result {
                    
                case .success(let url):
                    mPeople.userImage = url.absoluteString
                    
                    //save user to FireStore
                    do {
                        try self?.usersReference.document(mPeople.id).setData(from: mPeople)
                        complition(.success(mPeople))
                    } catch { fatalError(error.localizedDescription) }
                    
                case .failure(_):
                    fatalError("Cant upload Image") 
                }
            }
        } else {
             //save user to FireStore with default image
            do {
                try usersReference.document(mPeople.id).setData(from: mPeople)
                complition(.success(mPeople))
            } catch { fatalError(error.localizedDescription) }
        }
       
        
    }
    
    //MARK: - getUserData
    
    func getUserData(user: User, complition: @escaping (Result<MPeople,Error>) -> Void) {
        
        let documentReference = usersReference.document(user.uid)
        documentReference.getDocument { (snapshot, error) in
            
            
            if let snapshot = snapshot, snapshot.exists {
                
                /*  FirebaseFirestoreSwift
                 
                 let result = Result {
                 try snapshot.data(as: MPeople.self)
                 }
                 switch result {
                 case .success(let mPeople):
                 if let mPeople = mPeople {
                 complition(.success(mPeople))
                 } else {
                 complition(.failure(UserError.incorrectSetProfile))
                 }
                 
                 case .failure(let error):
                 fatalError(error.localizedDescription)
                 }
                 */
                
                
                // for control old users data, use this method
                
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
}


