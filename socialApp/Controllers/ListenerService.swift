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

class ListenerService {
    
    static let shared = ListenerService()
    private init() { }
    private let db = Firestore.firestore()
    private var userRef: CollectionReference {
        db.collection("users")
    }
    private var currentUser: User? {
        Auth.auth().currentUser
    }
    
    func addListener(users: [MPeople], complition: @escaping (Result<[MPeople], Error>) -> Void) -> ListenerRegistration {
        
        var currentUsers = users
        let listener = userRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { complition(.failure(error!)); return}
            
            snapshot.documentChanges.forEach {[weak self] changes in
                guard let user = MPeople(documentSnap: changes.document) else { return }
                switch changes.type {
                    
                case .added:
                    guard !currentUsers.contains(user) else { return }
                    guard user.id != self?.currentUser?.uid else { return }
                    currentUsers.append(user)
                case .modified:
                    guard let index = currentUsers.firstIndex(of: user) else {
                         print("Don't have this user id")
                        return }
                    print("user index \(index)")
                    currentUsers[index] = user
                case .removed:
                    guard let index = currentUsers.firstIndex(of: user) else { return }
                    currentUsers.remove(at: index)
                }
            }
            complition(.success(currentUsers))
        }
    
        return listener
    }
}
