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
        storegeRef.child("avatars")
    }
    
    private var chatsImageRef: StorageReference {
        storegeRef.child("chatsImage")
    }
    
    private var currentUserID: String? {
        Auth.auth().currentUser?.email
    }
    
    //MARK:  getImage
    func getImage(link: String?, complition: @escaping (Result<UIImage,Error>)->Void ) {
        
        guard let link = link else { complition(.failure(StorageError.referenceError)); return}
        
        let ref =  Storage.storage().reference(forURL: link)
        let maxDownloadSize:Int64 = 3 * 1024 * 1024
        
        ref.getData(maxSize: maxDownloadSize) { data, error in
            
            if let data = data {
                guard let image = UIImage(data: data) else {
                    complition(.failure(StorageError.getImageFromDataError))
                    return
                }
                complition(.success(image))
            } else if let error = error {
                complition(.failure(error))
            }
        }
    }
    
    //MARK: deleteImage
    func deleteImage(link: String, complition:@escaping(Result<String, Error>) -> Void ) {
        let ref = Storage.storage().reference(forURL: link)
    
        ref.delete { error in
            if let error = error {
                complition(.failure(error))
            } else {
                complition(.success(link))
            }
        }
    }
    
    //MARK:  uploadImage
    func uploadImage(image: UIImage, complition: @escaping (Result<URL,Error>)->Void ) {
        
        let scaleImage = image.resizeImage(targetLength: 400)
        guard let compressionImageData = scaleImage.jpegData(compressionQuality: 0.4) else { fatalError("cant compress image")}
        
        guard let userID = currentUserID else { fatalError("Cant get current user ID for upload image")}
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let uuid = UUID().uuidString
        avatarRef.child(userID).child(uuid).putData(compressionImageData,
                                        metadata: metadata) {[weak self] metadata, error in
            guard let _ = metadata else {
                complition(.failure(error!))
                return
            }
            self?.avatarRef.child(userID).child(uuid).downloadURL(completion: { url, error in
                guard let downloadURL = url else {
                    complition(.failure(error!))
                    return
                }
                complition(.success(downloadURL))
            })
        }
    }
    
    //MARK:  uploadChatImage
    func uploadChatImage(image: UIImage, currentUserID: String, chat: MChat, complition: @escaping (Result<URL,Error>)->Void ) {
        
        let scaleImage = image.resizeImage(targetLength: 400)
        guard let compressionImageData = scaleImage.jpegData(compressionQuality: 0.4) else { fatalError("cant compress image")}
        
        let currentDate = Date().getFormattedDate(format: "yyyy-MM-dd HH:mm:ss")
        let currentChatRef = chatsImageRef.child([currentUserID, chat.friendId].joined(separator: "_"))
        let currentImageRef = currentChatRef.child([currentDate, "chatImage", currentUserID].joined(separator: "_"))
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        currentImageRef.putData(compressionImageData,
                                metadata: metadata) { metadata, error in
            guard let _ = metadata else {
                complition(.failure(error!))
                return
            }
                currentImageRef.downloadURL(completion: { url, error in
                guard let downloadURL = url else {
                    complition(.failure(error!))
                    return
                }
                complition(.success(downloadURL))
            })
        }
    }
    
    //MARK: deleteChatImages
    func deleteChatImages(currentUserID: String, friendUserID: String) {
        let currentChatRef = chatsImageRef.child([currentUserID, friendUserID].joined(separator: "_"))
        let userChatRef = chatsImageRef.child([friendUserID, currentUserID].joined(separator: "_"))
        
        currentChatRef.listAll { result, error in
            guard error == nil else { return }
            for photo in result.items {
                photo.delete { error in
                    if let error = error {
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
        
        userChatRef.listAll { result, error in
            guard error == nil else { return }
            for photo in result.items {
                photo.delete { error in
                    if let error = error {
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    //MARK: deleteProfileImages
    func deleteProfileImages(userID: String) {
        let currentAvatarsRef = avatarRef.child(userID)
       
        currentAvatarsRef.listAll { result, error in
            guard error == nil else { return }
            for photo in result.items {
                photo.delete { error in
                    if let error = error {
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
    }
}

