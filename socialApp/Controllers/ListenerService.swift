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

    private let db = Firestore.firestore()
    private var userRef: CollectionReference {
        db.collection("users")
    }
    private var peopleListner: ListenerRegistration?
    private var currentUser: User? {
        Auth.auth().currentUser
    }
    private weak var delegate: PeopleListenerDelegate?
    
    private init() {}
    
    func addPeopleListener(delegate: PeopleListenerDelegate) {
        
        self.delegate = delegate
        peopleListner = userRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { fatalError(ListenerError.snapshotNotExist.localizedDescription) }
            
            snapshot.documentChanges.forEach {[weak self] changes in
                guard let user = MPeople(documentSnap: changes.document) else { fatalError(UserError.getUserData.localizedDescription) }
                guard let people = self?.delegate?.peopleNearby else { fatalError(ListenerError.peopleCollectionNotExist.localizedDescription) }
                switch changes.type {
                    
                case .added:
                    guard !people.contains(user) else { return }
                    guard user.id != self?.currentUser?.uid else { return }
                    guard user.isActive == true else { return }
                    self?.delegate?.peopleNearby.append(user)
                    self?.delegate?.reloadData()
                    
                case .modified:
                    if let index = people.firstIndex(of: user) {
                        if user.isActive == true {
                            self?.delegate?.peopleNearby[index] = user
                            self?.delegate?.updateData()
                        } else { //if user change to deactive profile delete him from collection
                            self?.delegate?.peopleNearby.remove(at: index)
                            self?.delegate?.reloadData()
                        }
                        //if user change to active profile add him to collection
                    } else if user.isActive == true, user.id != self?.currentUser?.uid { 
                        self?.delegate?.peopleNearby.append(user)
                        self?.delegate?.reloadData()
                    }
                    
                case .removed:
                    guard let index = people.firstIndex(of: user) else { return }
                    self?.delegate?.peopleNearby.remove(at: index)
                    self?.delegate?.reloadData()
                }
            }
        }
    }
    
    func removePeopleListener() {
        peopleListner?.remove()
    }
}
