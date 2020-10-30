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

protocol CollectionCellModel {
    func image() -> UIImage
    func description() -> String
}

protocol ReprasentationModel {
    var reprasentation:[String : Any]{ get }
    init?(documentSnap: DocumentSnapshot)
    init?(documentSnap: QueryDocumentSnapshot)
}

protocol NavigationDelegate: class {
    func toMainTabBarController(userID: String)
    func toCompliteRegistration(userID: String)
}

protocol LikeDislikeTappedDelegate: class {
    func likePeople(people: MPeople)
    func dislikePeople(people: MPeople)
}

//MARK: collection view protocol
protocol PeopleCollectionViewDelegate: class {
    func updateData()
    func reloadData(reloadSection: Bool, animating: Bool)
}

protocol RequestChatCollectionViewDelegate: class {
    func reloadData()
}

protocol AcceptChatCollectionViewDelegate: class {
    func reloadDataSource(searchText: String?)
    func updateDataSource()
}

protocol MessageControllerDelegate: class {
    var isInitiateDeleteChat: Bool { get set }
    
    func newMessage()
    func showChatAlert(text: String)
    
}

//MARK: listner Firestore protocols
protocol LikeDislikeListenerDelegate: class {
    var likePeople: [MChat] { get set }
    var dislikePeople: [MChat] { get set }
    
    func getLike(complition: @escaping (Result<[MChat], Error>) -> Void)
    func getDislike(complition: @escaping (Result<[MChat], Error>) -> Void)
}

protocol RequestChatListenerDelegate: class {
    var requestChats: [MChat] { get set }
    var sortedRequestChats: [MChat] { get }
    var requestChatCollectionViewDelegate: RequestChatCollectionViewDelegate? { get set }
    //first time get data
    func getRequestChats(complition: @escaping (Result<[MChat], Error>) -> Void)
    //work with collectionView
    func reloadData(changeType: MTypeOfListenerChanges)
    //work with listner
    func setupListener(likeDislikeDelegate: LikeDislikeListenerDelegate)
    func removeListener()
    func reloadListener(currentPeople: MPeople, likeDislikeDelegate: LikeDislikeListenerDelegate)
}

protocol AcceptChatListenerDelegate: class {
    var acceptChats: [MChat] { get set }
    var sortedAcceptChats: [MChat] { get }
    var acceptChatCollectionViewDelegate: AcceptChatCollectionViewDelegate? { get set }
    
    func reloadData(changeType: MTypeOfListenerChanges) 
    func getAcceptChats(complition: @escaping (Result<[MChat], Error>) -> Void)
    func setupListener()
    func removeListener()
}

protocol PeopleListenerDelegate: class {
    var peopleNearby: [MPeople] { get set }
    var sortedPeopleNearby: [MPeople] { get }
    var peopleCollectionViewDelegate: PeopleCollectionViewDelegate? { get set }
    //work with listner
    func setupListener(currentPeople: MPeople, likeDislikeDelegate: LikeDislikeListenerDelegate, acceptChatsDelegate: AcceptChatListenerDelegate) 
    func removeListener()
    func reloadListener(currentPeople: MPeople, likeDislikeDelegate: LikeDislikeListenerDelegate, acceptChatsDelegate: AcceptChatListenerDelegate)
    //work with collectionView
    func updateData()
    func reloadData(reloadSection: Bool, animating: Bool)
}

protocol MessageListenerDelegate: class {
    var messages:[MMessage] { get set }
    var messageControllerDelegate: MessageControllerDelegate? { get set }
    
    func setupListener(chat: MChat)
    func removeListener()
}

protocol ActiveChatListenerDelegate: class {
    var activeChats: [MChat] { get set }
    func reloadData(changeType: MTypeOfListenerChanges)
}



