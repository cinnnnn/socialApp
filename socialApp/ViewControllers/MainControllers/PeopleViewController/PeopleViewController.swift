//
//  PeopleViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 05.07.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class PeopleViewController: UIViewController {
    
    var currentPeople: MPeople
    weak var peopleDelegate: PeopleListenerDelegate?
    weak var requestChatDelegate: RequestChatListenerDelegate?
    weak var likeDislikeDelegate: LikeDislikeListenerDelegate?
    weak var acceptChatDelegate: AcceptChatListenerDelegate?
    
    var visibleIndexPath: IndexPath?
    var infoLabel = UILabel(labelText: "", textFont: .avenirBold(size: 38))
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<SectionsPeople, MPeople>?
    
    init(currentPeople: MPeople,
         peopleDelegate: PeopleListenerDelegate?,
         requestChatDelegate: RequestChatListenerDelegate?,
         likeDislikeDelegate: LikeDislikeListenerDelegate?,
         acceptChatDelegate: AcceptChatListenerDelegate?) {
        
        self.peopleDelegate = peopleDelegate
        self.requestChatDelegate = requestChatDelegate
        self.likeDislikeDelegate = likeDislikeDelegate
        self.acceptChatDelegate = acceptChatDelegate
        self.currentPeople = currentPeople
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        peopleDelegate?.removeListener()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupDiffebleDataSource()
        setup()
        setupConstraints()
        setupListner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK:  setup VC
    private func setup() {
        view.backgroundColor = .myWhiteColor()
        navigationItem.backButtonTitle = ""
    }
    
    private func setupListner() {
        guard let likeDislikeDelegate = likeDislikeDelegate else { fatalError("Can't get likeDislikeDelegate")}
        guard let acceptChatDelegate = acceptChatDelegate else { fatalError("Can't get acceptChatDelegate")}
        
        peopleDelegate?.setupListener(currentPeople: currentPeople,
                                            likeDislikeDelegate: likeDislikeDelegate,
                                            acceptChatsDelegate: acceptChatDelegate)
    }
    
    //MARK: setupCollectionView
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds,
                                          collectionViewLayout: setupCompositionLayout())
        
        collectionView.backgroundColor = nil
        collectionView.delegate = self
        
        collectionView.alwaysBounceVertical = false
        
        collectionView.register(PeopleCell.self,
                                forCellWithReuseIdentifier: PeopleCell.reuseID)
        collectionView.register(SectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SectionHeader.reuseId)
    }
    
    //MARK: setupMainSection
    private func setupMainSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                               heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                     subitems: [item])
        
    
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 40
        section.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                        leading: 20,
                                                        bottom: 0,
                                                        trailing: 20)
        
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, point, environment in

            self?.setUIForVisivleCells(items: visibleItems, point: point, enviroment: environment)
            
        }
        return section
    }
    
    //MARK: setupCompositionLayout
    private func setupCompositionLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment -> NSCollectionLayoutSection? in
            guard let section = SectionsPeople(rawValue: sectionIndex) else { fatalError("Unknown people section")}
            
            switch section {
            case .main:
                return self?.setupMainSection()
            }
        }
        return layout
    }
    //MARK: configureCell
    private  func configureCell(value: MPeople, indexPath: IndexPath) -> PeopleCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PeopleCell.reuseID, for: indexPath) as? PeopleCell else { fatalError("Can't dequeue cell type PeopleCell")}
        cell.likeDislikeDelegate = self
        cell.configure(with: value) {
            cell.layoutIfNeeded()
        }
        return cell
    }
    
    //MARK: setupDataSource
    private func setupDiffebleDataSource() {
        dataSource = UICollectionViewDiffableDataSource<SectionsPeople,MPeople>(
            collectionView: collectionView,
            cellProvider: { [weak self] (collectionView, indexPath, people) -> UICollectionViewCell? in
                guard let section = SectionsPeople(rawValue: indexPath.section) else { fatalError("Unknown people section")}
                
                switch section {
                case .main:
                    return self?.configureCell(value: people,
                                               indexPath: indexPath)
                }
        })
    }
}

//MARK: set empty data
extension PeopleViewController {
    private func checkPeopleNearbyIsEmpty()  {
        //if nearby people empty set
        guard let sortedPeopleNearby = peopleDelegate?.sortedPeopleNearby else { fatalError() }
        if sortedPeopleNearby.isEmpty {
            infoLabel.isHidden = false
            infoLabel.text = MLabels.emptyNearbyPeople.rawValue
        } else {
            infoLabel.isHidden = true
        }
    }
}

//MARK: setUIForVisivleCells
extension PeopleViewController {
    private func setUIForVisivleCells(items: [NSCollectionLayoutVisibleItem], point: CGPoint, enviroment: NSCollectionLayoutEnvironment) {
       
        items.forEach { visibleItem in
            let distanceFromCenter = abs((visibleItem.frame.midX - point.x) - enviroment.container.contentSize.width / 2.0)
            let minScale: CGFloat = 0.5
            let maxScale: CGFloat = 1
            let scale = max(maxScale - (distanceFromCenter / enviroment.container.contentSize.width / 2), minScale)
            visibleItem.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
}

//MARK: - PeopleCollectionViewDelegate
extension PeopleViewController: PeopleCollectionViewDelegate {
    
    
    //MARK:  updateData
    func updateData() {
        guard var snapshot = dataSource?.snapshot() else { return }
        guard let sortedPeopleNearby = peopleDelegate?.sortedPeopleNearby else { fatalError() }
        snapshot.appendItems(sortedPeopleNearby, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: true)
        
        checkPeopleNearbyIsEmpty()
    }
    
    
    //MARK:  reloadData
    func reloadData(reloadSection: Bool = false, animating: Bool = true) {
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionsPeople,MPeople>()
        snapshot.appendSections([.main])
        guard let sortedPeopleNearby = peopleDelegate?.sortedPeopleNearby else { fatalError() }
        snapshot.appendItems(sortedPeopleNearby, toSection: .main)
        
        if reloadSection {
            snapshot.reloadSections([.main])
        }
        dataSource?.apply(snapshot, animatingDifferences: animating)
        
        checkPeopleNearbyIsEmpty()
    }
}



//MARK:  UICollectionViewDelegate
extension PeopleViewController: UICollectionViewDelegate {
    
}

//MARK: likeDislikeDelegate
extension PeopleViewController: LikeDislikeTappedDelegate {
    
     func likePeople(people: MPeople) {
        //save like to firestore
        FirestoreService.shared.likePeople(currentPeople: currentPeople,
                                           likePeople: people,
                                           requestChats: requestChatDelegate?.requestChats ?? []) {[weak self] result, isMatch  in
            switch result {
            
            case .success(let likeChat):
                //delete like people from array
                self?.likeDislikeDelegate?.likePeople.append(likeChat)
                self?.peopleDelegate?.peopleNearby.removeAll { people -> Bool in
                    people.senderId == likeChat.friendId
                }
                //for correct reload last element, need reload section
                self?.reloadData(reloadSection: self?.peopleDelegate?.peopleNearby.count == 1 ? true : false)
                if isMatch {
                    guard let currentPeople = self?.currentPeople else { return }
                    PopUpService.shared.showMatchPopUP(currentPeople: currentPeople, chat: likeChat) { messageDelegate, acceptChatDelegate in
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
        //save dislike from firestore
        print("dislike \(people.displayName)")
        FirestoreService.shared.dislikePeople(currentPeople: currentPeople,
                                              dislikeForPeople: people,
                                              requestChats: requestChatDelegate?.requestChats ?? []) {[weak self] result in
            switch result {
            
            case .success(let dislikeChat):
                //delete dislike people from array
                self?.peopleDelegate?.peopleNearby.removeAll { people -> Bool in
                    people.senderId == dislikeChat.friendId
                }
                //for correct reload last element, need reload section
                self?.reloadData(reloadSection: self?.peopleDelegate?.peopleNearby.count == 1 ? true : false)
                
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
}

//MARK: setupConstraints
extension PeopleViewController {
    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
       
        view.addSubview(collectionView)
        view.addSubview(infoLabel)
        
        NSLayoutConstraint.activate([
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            infoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
