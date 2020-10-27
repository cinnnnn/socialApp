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


class RequestsViewController: UIViewController, RequestChatDelegate {
    
    var collectionView: UICollectionView?
    var requestChats: [MChat] = []
    var sortedRequestChats: [MChat] {
        let request = requestChats.sorted {
            $0.date > $1.date
        }
        return request
    }
    weak var peopleListnerDelegate: PeopleListenerDelegate?
    weak var likeDislikeDelegate: LikeDislikeDelegate?
    var dataSource: UICollectionViewDiffableDataSource<SectionsRequests, MChat>?
    var currentPeople: MPeople
    
    init(currentPeople: MPeople, likeDislikeDelegate: LikeDislikeDelegate) {
        self.currentPeople = currentPeople
        self.likeDislikeDelegate = likeDislikeDelegate
        super.init(nibName: nil, bundle: nil)
        setupListeners()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ListenerService.shared.removeRequestChatsListener()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupCollectionView()
        setupDataSource()
        loadSectionHedear()
        reloadDataSource(searchText: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCurrentPeople()
    }
    
    private func setupListeners() {
        guard let likeDislikeDelegate = likeDislikeDelegate else { fatalError("likeDislikeDelegate is nil") }
        ListenerService.shared.addRequestChatsListener(currentPeople: currentPeople,
                                                       requestChatDelegate: self,
                                                       likeDislikeDelegate: likeDislikeDelegate)
    }
    
    private func updateCurrentPeople() {
        if let people = UserDefaultsService.shared.getMpeople() {
            currentPeople = people
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.backButtonTitle = ""
        navigationItem.largeTitleDisplayMode = .never
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
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let grupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4),
                                              heightDimension: .fractionalHeight(0.4))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: grupSize,
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 15
        section.contentInsets = NSDirectionalEdgeInsets(top: 10,
                                                        leading: 20,
                                                        bottom: 0,
                                                        trailing: 20)
        return section
    }
}

//MARK:  DiffableDataSource
extension RequestsViewController {
    //MARK:  configure  cell
    private func configure<T: SelfConfiguringCell>(cellType: T.Type, value: MChat, indexPath: IndexPath) -> T {
        guard let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: cellType.reuseID, for: indexPath) as? T else { fatalError("Can't dequeue cell type \(cellType)") }
        
        cell.configure(with: value)
        return cell
    }
    
    //MARK:  setupDataSource
    private func setupDataSource(){
        guard let collectionView = collectionView else { fatalError("CollectionView is nil")}
        dataSource = UICollectionViewDiffableDataSource<SectionsRequests, MChat>(
            collectionView: collectionView,
            cellProvider: { [weak self] (collectionView, indexPath, chat) -> UICollectionViewCell? in
                
                guard let section = SectionsRequests(rawValue: indexPath.section) else {
                    fatalError("Unknown Section")
                }
                
                switch section {
                case .requestChats:
                    return self?.configure(cellType: RequestChatCell.self, value: chat, indexPath: indexPath)
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
    
    //MARK:  reloadData
    private func reloadDataSource(searchText: String? = nil){
        var snapshot = NSDiffableDataSourceSnapshot<SectionsRequests, MChat>()
        snapshot.appendSections([.requestChats])
        snapshot.appendItems(sortedRequestChats, toSection: .requestChats)
        dataSource?.apply(snapshot, animatingDifferences: true)
        
        updateHeader()
    }
    //MARK:  updateHeader
    private func updateHeader() {
        guard var snapshot = dataSource?.snapshot() else { return }
        let activeSection = snapshot.sectionIdentifiers
        snapshot.reloadSections(activeSection)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
}


extension RequestsViewController: RequestChatListenerDelegate {
    //MARK: reloadRequestData
    func reloadData(changeType: MTypeOfListenerChanges) {
        reloadDataSource()
    }
    
    //MARK: reloadListner
    func reloadListner() {
        requestChats = []
        reloadDataSource()
        ListenerService.shared.removeRequestChatsListener()
        setupListeners()
        //reload listner peopleNearby VC
        peopleListnerDelegate?.reloadListner()
    }
}

//MARK: CollectionViewDelegate
extension RequestsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = SectionsRequests(rawValue: indexPath.section) else { fatalError("Unknow section index")}
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { fatalError(DataSourceError.unknownChatIdentificator.localizedDescription)}
        
        switch section {
        case .requestChats:
            let peopleVC = PeopleInfoViewController(peopleID: item.friendId, withLikeButtons: true)
            peopleVC.requestChatsDelegate = self
            peopleVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(peopleVC, animated: true)
        }
    }
}
