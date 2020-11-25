//
//  RequestsViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 17.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI
import FirebaseAuth


class RequestsViewController: UIViewController {
    
    var collectionView: UICollectionView?
   
    var peopleDelegate: PeopleListenerDelegate
    var requestChatDelegate: RequestChatListenerDelegate
    var likeDislikeDelegate: LikeDislikeListenerDelegate
    var acceptChatDelegate: AcceptChatListenerDelegate
    
    var dataSource: UICollectionViewDiffableDataSource<SectionsRequests, MChat>?
    var currentPeople: MPeople
    
    init(currentPeople: MPeople,
         likeDislikeDelegate: LikeDislikeListenerDelegate,
         requestChatDelegate: RequestChatListenerDelegate,
         peopleNearbyDelegate: PeopleListenerDelegate,
         acceptChatDelegate: AcceptChatListenerDelegate) {
        
        self.currentPeople = currentPeople
        self.peopleDelegate = peopleNearbyDelegate
        self.requestChatDelegate = requestChatDelegate
        self.likeDislikeDelegate = likeDislikeDelegate
        self.acceptChatDelegate = acceptChatDelegate
        super.init(nibName: nil, bundle: nil)
        setupListeners()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        requestChatDelegate.removeListener()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupDataSource()
        loadSectionHedear()
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCurrentPeople()
        setupNavigationBar()
        reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    private func setupListeners() {
        requestChatDelegate.setupListener(likeDislikeDelegate: likeDislikeDelegate)
        NotificationCenter.addObsorverToCurrentUser(observer: self, selector: #selector(updateCurrentPeople))
        NotificationCenter.addObsorverToPremiumUpdate(observer: self, selector: #selector(premiumIsUpdated))
    }
    
    
    //MARK: objc
    @objc private func updateCurrentPeople() {
        if let people = UserDefaultsService.shared.getMpeople() {
            currentPeople = people
        }
    }
    
    @objc private func premiumIsUpdated() {
        reloadData()
    }
    
    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //MARK:  setupCollectionView
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds,
                                          collectionViewLayout: setupCompositionalLayout())
        
        guard let collectionView = collectionView else { fatalError("CollectionView is nil")}
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .myWhiteColor()
        collectionView.delegate = self
  

        collectionView.register(RequestChatCell.self, forCellWithReuseIdentifier: RequestChatCell.reuseID)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
    }
}

//MARK:  setupCompositionLayout
extension RequestsViewController {
    
    private func setupCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let section = SectionsRequests(rawValue: sectionIndex) else { fatalError("Unknown section")}
            
            switch section {
            case .requestChats:
                return self.createRequestChatsLayout()
            }
        }
        return layout
    }
    
    //MARK:  createSectionHeader
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let sectionSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                 heightDimension: .estimated(1))
        
        let item = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionSize,
                                                               elementKind: UICollectionView.elementKindSectionHeader,
                                                               alignment: .top)
        
        return item
    }
    //MARK:  createRequestChatsLayout
    private func createRequestChatsLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .estimated(100))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let grupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .estimated(100))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: grupSize,
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
    
        section.interGroupSpacing = 15
        section.contentInsets = NSDirectionalEdgeInsets(top: 40,
                                                        leading: 20,
                                                        bottom: 0,
                                                        trailing: 20)
        return section
    }
}

//MARK:  DiffableDataSource
extension RequestsViewController {

    //MARK:  setupDataSource
    private func setupDataSource(){
        guard let collectionView = collectionView else { fatalError("CollectionView is nil")}
        dataSource = UICollectionViewDiffableDataSource<SectionsRequests, MChat>(
            collectionView: collectionView,
            cellProvider: {[weak self] collectionView, indexPath, chat -> UICollectionViewCell? in
                
                guard let section = SectionsRequests(rawValue: indexPath.section) else {
                    fatalError("Unknown Section")
                }
                
                switch section {
                case .requestChats:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RequestChatCell.reuseID,
                                                                        for: indexPath) as? RequestChatCell else {
                        fatalError("Can't dequeue cell type \(RequestChatCell.self)")
                    }
                    if let currentPeople = self?.currentPeople {
                        cell.configure(with: chat, currentUser: currentPeople)
                    }
                    return cell
                }
            })
    }
    
    //MARK:  supplementaryViewProvider
    private func loadSectionHedear() {
        dataSource?.supplementaryViewProvider = {
            collectionView, kind, indexPath in
            guard let reuseSectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else { fatalError("Can't create new sectionHeader") }
            
            guard let section = SectionsRequests(rawValue: indexPath.section) else { fatalError("Unknown section")}
            guard let itemsCount = self.dataSource?.snapshot().numberOfItems(inSection: section) else { fatalError("Unknow items count in section")}
            
            reuseSectionHeader.configure(text: section.description(count: itemsCount),
                                         font: .avenirRegular(size: 12),
                                         textColor: UIColor.myGrayColor())
            
            return reuseSectionHeader
        }
    }
    
}

extension RequestsViewController: RequestChatCollectionViewDelegate {
    //MARK: reloadRequestData
    func reloadData() {
    
        
        let sortedRequestChats = requestChatDelegate.sortedRequestChats
        
        if let dataSource = dataSource {
            var snapshot = dataSource.snapshot()
            snapshot.deleteAllItems()
            snapshot.appendSections([.requestChats])
            snapshot.appendItems(sortedRequestChats, toSection: .requestChats)
            dataSource.apply(snapshot, animatingDifferences: false)
        } else {
            var snapshot = NSDiffableDataSourceSnapshot<SectionsRequests, MChat>()
            snapshot.appendSections([.requestChats])
            snapshot.appendItems(sortedRequestChats, toSection: .requestChats)
            dataSource?.apply(snapshot, animatingDifferences: true) { [weak self] in
                //for update header
                guard let snapshot2 = self?.dataSource?.snapshot() else { return }
                self?.dataSource?.apply(snapshot2, animatingDifferences: false)
            }
        }
    }
}

//MARK: CollectionViewDelegate
extension RequestsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = SectionsRequests(rawValue: indexPath.section) else { fatalError("Unknow section index")}
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { fatalError(DataSourceError.unknownChatIdentificator.localizedDescription)}
        
        switch section {
        case .requestChats:
            if currentPeople.isGoldMember || currentPeople.isTestUser {
                let peopleVC = PeopleInfoViewController(peopleID: item.friendId, withLikeButtons: true)
                peopleVC.requestChatsDelegate = requestChatDelegate
                peopleVC.peopleDelegate = peopleDelegate
                peopleVC.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(peopleVC, animated: true)
            } else {
                var popUpHeader = "Видеть кто тебя лайкнул"
                var popUpMessage = "Возможно с подпиской Flava Premium"
                let requestChatCount = requestChatDelegate.requestChats.count
                let waitText = requestChatCount == 1 ? "ждет" : "ждут"
                let peopleText = requestChatCount == 1 ? "человек" : "человек(а)"
                popUpHeader = "\(requestChatCount) \(peopleText) \(waitText) ответа"
                popUpMessage = "Хочешь видеть? И образовывать пары сразу?"
                
                PopUpService.shared.bottomPopUp(header: popUpHeader,
                                                text: popUpMessage,
                                                image: nil,
                                                okButtonText: "Перейти на Flava premium") { [ weak self] in
                    
                    guard let currentPeople = self?.currentPeople else { return }
                    let purchasVC = PurchasesViewController(currentPeople: currentPeople)
                    purchasVC.modalPresentationStyle = .fullScreen
                    self?.present(purchasVC, animated: true, completion: nil)
                }
            }
        }
    }
}
