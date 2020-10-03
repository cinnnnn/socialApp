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
    func configure(with value: MPeople, complition:@escaping()->Void)
}

protocol PeopleCellDelegate: class {
    func updateCell(user: MPeople)
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
