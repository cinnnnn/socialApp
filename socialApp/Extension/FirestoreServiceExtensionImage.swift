//
//  FirestoreServiceImageExtension.swift
//  socialApp
//
//  Created by Денис Щиголев on 19.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase
import FirebaseAuth

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
                    self?.usersReference.document(id).setData([MPeople.CodingKeys.userImage.rawValue : userImageString,
                                                               MPeople.CodingKeys.lastActiveDate.rawValue : Date()],
                                                              merge: true,
                                                              completion: { error in
                                                                if let error = error {
                                                                    complition(.failure(error))
                                                                } else {
                                                                    //edit current user from UserDefaults for save request to server
                                                                    if var people = UserDefaultsService.shared.getMpeople() {
                                                                        people.userImage = userImageString
                                                                        people.lastActiveDate = Date()
                                                                        UserDefaultsService.shared.saveMpeople(people: people)
                                                                        NotificationCenter.postCurrentUserNeedUpdate()
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
            [MPeople.CodingKeys.userImage.rawValue : imageURLString,
             MPeople.CodingKeys.lastActiveDate.rawValue : Date()],
            merge: true,
            completion: {[weak self] error in
                
                if let error = error {
                    complition(.failure(error))
                } else {
                    //edit current user from UserDefaults for save request to server
                    if var people = UserDefaultsService.shared.getMpeople() {
                        people.userImage = imageURLString
                        people.lastActiveDate = Date()
                        UserDefaultsService.shared.saveMpeople(people: people)
                        NotificationCenter.postCurrentUserNeedUpdate()
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
                    self?.usersReference.document(id).setData([MPeople.CodingKeys.gallery.rawValue : FieldValue.arrayUnion([userImageString]),
                                                               MPeople.CodingKeys.lastActiveDate.rawValue : Date()],
                                                              merge: true,
                                                              completion: { error in
                                                                if let error = error {
                                                                    complition(.failure(error))
                                                                } else {
                                                                    //edit current user from UserDefaults for save request to server
                                                                    if var people = UserDefaultsService.shared.getMpeople() {
                                                                        people.gallery.append(userImageString)
                                                                        people.lastActiveDate = Date()
                                                                        UserDefaultsService.shared.saveMpeople(people: people)
                                                                        NotificationCenter.postCurrentUserNeedUpdate()
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
            usersReference.document(id).setData([MPeople.CodingKeys.gallery.rawValue : FieldValue.arrayUnion([imageLink]),
                                                 MPeople.CodingKeys.lastActiveDate.rawValue : Date()],
                                                merge: true,
                                                completion: { error in
                                                    if let error = error {
                                                        complition(.failure(error))
                                                    } else {
                                                        //edit current user from UserDefaults for save request to server
                                                        if var people = UserDefaultsService.shared.getMpeople() {
                                                            people.gallery.append(imageLink)
                                                            people.lastActiveDate = Date()
                                                            UserDefaultsService.shared.saveMpeople(people: people)
                                                            NotificationCenter.postCurrentUserNeedUpdate()
                                                        }
                                                        complition(.success(imageLink))
                                                    }
                                                })
        }
    }
    
    //MARK: deleteFromGallery
    func deleteFromGallery(imageURLString: String, deleteInStorage:Bool = true,  id: String, complition:@escaping(Result<String, Error>) -> Void) {
        
        //delete image from array in Firestore
        usersReference.document(id).setData([MPeople.CodingKeys.gallery.rawValue : FieldValue.arrayRemove([imageURLString]),
                                             MPeople.CodingKeys.lastActiveDate.rawValue : Date()],
                                            merge: true,
                                            completion: { error in
                                                if let error = error {
                                                    complition(.failure(error))
                                                } else {
                                                    //edit current user from UserDefaults for save request to server
                                                    if var people = UserDefaultsService.shared.getMpeople() {
                                                        guard let indexOfImage = people.gallery.firstIndex(of: imageURLString) else { return }
                                                        people.gallery.remove(at: indexOfImage)
                                                        people.lastActiveDate = Date()
                                                        UserDefaultsService.shared.saveMpeople(people: people)
                                                        NotificationCenter.postCurrentUserNeedUpdate()
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
