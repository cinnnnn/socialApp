//
//  StorageService.swift
//  socialApp
//
//  Created by Денис Щиголев on 09.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage

class StorageService {
    
    static let shared = StorageService()
    
    private init(){ }
    
    let storegeRef = Storage.storage().reference()
    
    private var avatarRef: StorageReference {
        return storegeRef.child("avatars")
    }
    
    private var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }
    
    func uploadImage(image: UIImage, complition: @escaping (Result<URL,Error>)->Void ) {
        
        let scaleImage = image.resizeImage(targetLength: 400)
        guard let compressionImageData = scaleImage.jpegData(compressionQuality: 0.4) else { fatalError("cant compress image")}
        
        guard let userID = currentUserID else { fatalError("Cant get current user ID for upload image")}
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        avatarRef.child(userID).putData(compressionImageData,
                                        metadata: metadata) {[weak self] metadata, error in
                                            guard let _ = metadata else {
                                                complition(.failure(error!))
                                                return
                                            }
                                            self?.avatarRef.child(userID).downloadURL(completion: { url, error in
                                                guard let downloadURL = url else {
                                                    complition(.failure(error!))
                                                    return
                                                }
                                                complition(.success(downloadURL))
                                            })
                                            
        }
    }
    
    
    
}

