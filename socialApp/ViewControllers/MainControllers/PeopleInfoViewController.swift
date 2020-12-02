//
//  PeopleInfoViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 26.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class PeopleInfoViewController: UIViewController {
    
    var peopleID: String
    var withLikeButtons: Bool
    weak var requestChatsDelegate: RequestChatListenerDelegate?
    weak var peopleDelegate: PeopleListenerDelegate?
    
    var currentPeople: MPeople?
    var people: MPeople?
    let peopleView = PeopleView()
    let loadingView = LoadingView(name: "explore", isHidden: false)
    
    init(peopleID: String, withLikeButtons: Bool) {
        self.peopleID = peopleID
        self.withLikeButtons = withLikeButtons
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configure()
        setupConstraints()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setup() {
        view.backgroundColor = .myWhiteColor()
        peopleView.animateLikeButton.isHidden = !withLikeButtons
        peopleView.animateDislikeButton.isHidden = !withLikeButtons
        peopleView.animateLikeButton.addTarget(self, action: #selector(likeTapped(sender:)), for: .touchUpInside)
        peopleView.animateDislikeButton.addTarget(self, action: #selector(dislikeTapped(sender:)), for: .touchUpInside)
        peopleView.timeButton.addTarget(self, action: #selector(timeTapped), for: .touchUpInside)
        peopleView.layoutIfNeeded()
        
        currentPeople = UserDefaultsService.shared.getMpeople()
    }
    
    func configure() {
        FirestoreService.shared.getUserData(userID: peopleID, complition: { [weak self] result in
            switch result {
            
            case .success(let mPeople):
                guard let currentPeople = self?.currentPeople else { return }
                self?.people = mPeople
                self?.peopleView.configure(with: mPeople, currentPeople: currentPeople, showPrivatePhoto: true) {
                    self?.loadingView.hide()
                }
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        })
    }
}

//MARK: obcj
extension PeopleInfoViewController {
    @objc private func likeTapped(sender: Any) {
        guard let people = people,
              let button = sender as? LikeDislikePeopleButton else {
            return
        }
        button.play { [weak self] in
            self?.likePeople(people: people)
        }

    }
    
    @objc private func dislikeTapped(sender: Any) {
        guard let people = people,
              let button = sender as? LikeDislikePeopleButton else {
            return
        }
        button.play { [weak self] in
            self?.dislikePeople(people: people)
        }
    }
    
}

extension PeopleInfoViewController: PeopleButtonTappedDelegate {
    
    @objc func timeTapped() {
        PopUpService.shared.bottomPopUp(header: "Хочешь видеть время последней активности пользователя?",
                                        text: "Последняя активность, и многое другое с подпиской Flava Premium",
                                        image: nil,
                                        okButtonText: "Перейти на Flava premium") { [ weak self] in
            
            guard let currentPeople = self?.currentPeople else { return }
            let purchasVC = PurchasesViewController(currentPeople: currentPeople)
            purchasVC.modalPresentationStyle = .fullScreen
            self?.present(purchasVC, animated: true, completion: nil)
        }
    }
    
     func likePeople(people: MPeople) {
        guard let currentPeople = currentPeople else { return }
        guard let requestChatsDelegate = requestChatsDelegate else { fatalError("Can't get requestChatsDelegate") }
        guard let peopleDelegate = peopleDelegate else {  fatalError("Can't get peopleDelegate")  }
      
        //save like to firestore
        FirestoreService.shared.likePeople(currentPeople: currentPeople,
                                           likePeople: people,
                                           requestChats: requestChatsDelegate.requestChats ) {[weak self] result, isMatch in
            switch result {
            
            case .success(let likeChat):
                
                peopleDelegate.peopleNearby.removeAll { peopleDelegate -> Bool in
                    peopleDelegate.senderId == people.senderId
                }
              
                self?.peopleView.animateLikeButton.isHidden = true
                self?.peopleView.animateDislikeButton.isHidden = true
                
                requestChatsDelegate.reloadData(changeType: .delete)
                //for correct renew last people, need reload section
                peopleDelegate.reloadData(reloadSection: self?.peopleDelegate?.peopleNearby.count == 1 ? true : false, animating: false)
                
                if isMatch {
                    PopUpService.shared.showMatchPopUP(currentPeople: currentPeople,
                                                       chat: likeChat) { messageDelegate, acceptChatDelegate in
                        let chatVC = ChatViewController(people: currentPeople,
                                                        chat: likeChat,
                                                        messageDelegate: messageDelegate,
                                                        acceptChatDelegate: acceptChatDelegate)
                        chatVC.hidesBottomBarWhenPushed = true
                        self?.navigationController?.pushViewController(chatVC, animated: true)
                    }
                }
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
     func dislikePeople(people: MPeople) {
        guard let currentPeople = currentPeople else { return }
        guard let requestChatsDelegate = requestChatsDelegate else { fatalError("Can't get requestChatsDelegate") }
        guard let peopleDelegate = peopleDelegate else {  fatalError("Can't get peopleDelegate")  }
        //save dislike from firestore
        FirestoreService.shared.dislikePeople(currentPeople: currentPeople,
                                              dislikeForPeopleID: people.senderId,
                                              requestChats: requestChatsDelegate.requestChats,
                                              viewControllerDelegate: self) {[weak self] result in
            switch result {
            
            case .success(_):
                peopleDelegate.peopleNearby.removeAll { peopleDelegate -> Bool in
                    peopleDelegate.senderId == people.senderId
                }
                
                self?.peopleView.animateLikeButton.isHidden = true
                self?.peopleView.animateDislikeButton.isHidden = true
                
                requestChatsDelegate.reloadData(changeType: .delete)
                //for correct renew last people, need reload section
                peopleDelegate.reloadData(reloadSection: self?.peopleDelegate?.peopleNearby.count == 1 ? true : false, animating: false)
                
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
}

//MARK: setupConstraints
extension PeopleInfoViewController {
    private func setupConstraints() {
        
        view.addSubview(peopleView)
        view.addSubview(loadingView)
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        peopleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            peopleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            peopleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            peopleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -20),
            peopleView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}


