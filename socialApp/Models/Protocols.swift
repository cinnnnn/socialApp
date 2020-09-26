//
//  Protocols.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

// configure cell of collectionView

protocol SelfConfiguringCell {
    static var reuseID: String { get }
    func configure(with value: MChat)
}

protocol PeopleConfigurationCell {
    static var reuseID: String { get }
    var delegate: PeopleCellDelegate? { get set}
    var likeButton: UIButton { get }
    func configure(with value: MPeople)
    
}

protocol PeopleCellDelegate: class {
    func likeTupped(user: MPeople)
}

protocol AuthNavigationDelegate: class {
    func toLogin()
    func toRegister(email:String?)
    func toGenderSelect(currentUser: User)
    func toWantSelect(currentUser: User)
    func toMainTabBar(currentUser: User)
}

protocol PeopleListenerDelegate: class {
    var peopleNearby: [MPeople] { get set }
    func updateData()
    func reloadData()
}

protocol RequestChatListenerDelegate: class {
    var requestChats: [MChat] { get set }
    func reloadRequestData()
}

protocol ActiveChatListenerDelegate: class {
    var activeChats: [MChat] { get set }
    func reloadActiveData()
    func updateActiveData()
}

//protocol UpdateCurrentMPeopleDelegate {
//    var currentPeople: MPeople? { get set }
//    func updatePeople(people: MPeople?)
//}

protocol ReprasentationModel {
    var reprasentation:[String : Any]{ get }
    init?(documentSnap: DocumentSnapshot)
    init?(documentSnap: QueryDocumentSnapshot)
}
