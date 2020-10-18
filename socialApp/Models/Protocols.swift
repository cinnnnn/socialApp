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
protocol SelfConfiguringCell: class {
    static var reuseID: String { get }
    func configure(with value: MChat)
}

protocol PeopleConfigurationCell: class {
    static var reuseID: String { get }
    func configure(with value: MPeople, complition:@escaping()->Void)
}

protocol LikeDislikeDelegate: class {
    func likePeople(people: MPeople)
    func dislikePeople(people: MPeople)
}

protocol PeopleListenerDelegate: class {
    var peopleNearby: [MPeople] { get set }
    func updateData()
    func reloadData()
}

protocol RequestChatDelegate: class {
    var requestChats: [MChat] { get set }
}

protocol RequestChatListenerDelegate: class {
    var requestChats: [MChat] { get set }
    func reloadData(changeType: TypeOfListenerChanges)
}

protocol NewChatListenerDelegate: class {
    var newChats: [MChat] { get set }
    func reloadData(changeType: TypeOfListenerChanges)
}

protocol ActiveChatListenerDelegate: class {
    var activeChats: [MChat] { get set }
    func reloadData(changeType: TypeOfListenerChanges)
}

protocol ReprasentationModel {
    var reprasentation:[String : Any]{ get }
    init?(documentSnap: DocumentSnapshot)
    init?(documentSnap: QueryDocumentSnapshot)
}

protocol NavigationDelegate: class {
    func toMainTabBarController(user: User)
    func toCompliteRegistration(user: User)
}

