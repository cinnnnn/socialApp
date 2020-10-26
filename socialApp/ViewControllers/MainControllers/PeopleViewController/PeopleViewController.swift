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

class PeopleViewController: UIViewController, PeopleListenerDelegate, LikeDislikeDelegate {
    
    weak var requestDelegate: RequestChatDelegate?
    weak var acceptChatsDelegate: AcceptChatsDelegate?
    var currentPeople: MPeople
    var likePeople: [MChat] = []
    var dislikePeople: [MChat] = []
    var peopleNearby: [MPeople] = []
    var sortedPeopleNearby: [MPeople] {
        peopleNearby.sorted { p1, p2  in
            p1.distance < p2.distance
        }
    }
    var visibleIndexPath: IndexPath?
    var infoLabel = UILabel(labelText: "", textFont: .avenirBold(size: 38))
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<SectionsPeople, MPeople>?
    
    init(currentPeople: MPeople) {
        self.currentPeople = currentPeople
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        removeListeners()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupDiffebleDataSource()
        setup()
        setupConstraints()
        setupListeners(forPeople: currentPeople)
        print(#function)
    }
    
    //MARK:  setup VC
    private func setup() {
        view.backgroundColor = .myWhiteColor()
        navigationItem.backButtonTitle = ""
    }
    
    //MARK:  setupListeners
    private func setupListeners(forPeople: MPeople) {

        //first get list of like people
        let userID = currentPeople.senderId
        FirestoreService.shared.getLikeDislikePeople(userID: userID,
                                                     collection: MFirestorCollection.likePeople.rawValue) {[weak self] result in
            switch result {
            
            case .success(let likeChats):
                self?.likePeople = likeChats
                //get list of dislike people
                FirestoreService.shared.getLikeDislikePeople(userID: userID,
                                                             collection: MFirestorCollection.dislikePeople.rawValue) { result in
                    switch result {
                    
                    case .success(let dislikeChat):
                        self?.dislikePeople = dislikeChat
                        //after get like and dislike setup people nearby listener
                        
                        guard let peopleDelegate = self else { return }
                        guard let likeDislikeDelegate = self else { return }
                        guard let newActiveChatsDelegate = self?.acceptChatsDelegate else { return }
                        
                        ListenerService.shared.addPeopleListener(currentPeople: forPeople,
                                                                 peopleDelegate: peopleDelegate,
                                                                 likeDislikeDelegate: likeDislikeDelegate,
                                                                 newActiveChatsDelegate: newActiveChatsDelegate)
                    case .failure(let error):
                        fatalError(error.localizedDescription)
                    }
                }
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
    private func removeListeners() {
        ListenerService.shared.removePeopleListener()
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
    
    //MARK: setupDiffebleDataSource
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
    
    //MARK:  updateData
    func updateData() {
        guard var snapshot = dataSource?.snapshot() else { return }
        snapshot.appendItems(sortedPeopleNearby, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: true)
        
        checkPeopleNearbyIsEmpty()
    }
    
    //MARK:  reloadData
    func reloadData(reloadSection: Bool = false, animating: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionsPeople,MPeople>()
        snapshot.appendSections([.main])
        snapshot.appendItems(sortedPeopleNearby, toSection: .main)
        
        if reloadSection {
            snapshot.reloadSections([.main])
        }
        dataSource?.apply(snapshot, animatingDifferences: animating)
        
        checkPeopleNearbyIsEmpty()
    }
    
    //MARK: reloadListner
    func reloadListner() {
        peopleNearby = []
        guard let updatePeople = UserDefaultsService.shared.getMpeople() else { return }
        currentPeople = updatePeople
        reloadData(reloadSection: false, animating: false)
        removeListeners()
        setupListeners(forPeople: updatePeople)
    }
}

//MARK:setDataForVisibleCell
extension PeopleViewController {
    private func checkPeopleNearbyIsEmpty()  {
        //if nearby people empty set 
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

//MARK:  objc
extension PeopleViewController {
    
    @objc private func touchGoToSetup() {
        tabBarController?.selectedIndex = 0
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
                                           requestChats: requestDelegate?.requestChats ?? []) {[weak self] result in
            switch result {
            
            case .success(let likeChat):
                //delete like people from array
                self?.peopleNearby.removeAll { people -> Bool in
                    people.senderId == likeChat.friendId
                }
                //for correct reload last element, need reload section
                self?.reloadData(reloadSection: self?.peopleNearby.count == 1 ? true : false)
                
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func dislikePeople(people: MPeople) {
        //save dislike from firestore
        FirestoreService.shared.dislikePeople(currentPeople: currentPeople,
                                              forPeople: people) {[weak self] result in
            switch result {
            
            case .success(let dislikeChat):
                //delete dislike people from array
                self?.peopleNearby.removeAll { people -> Bool in
                    people.senderId == dislikeChat.friendId
                }
                //for correct reload last element, need reload section
                self?.reloadData(reloadSection: self?.peopleNearby.count == 1 ? true : false)
                
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
