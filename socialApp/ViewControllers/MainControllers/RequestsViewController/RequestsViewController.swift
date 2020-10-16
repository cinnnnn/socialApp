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
    
    var collectionView: UICollectionView!
    var requestChats: [MChat] = []
    var sortedRequestChats: [MChat] {
        requestChats.sorted {
            $0.date > $1.date
        }
    }
    
    var dataSource: UICollectionViewDiffableDataSource<SectionsRequests, MChat>?
    var currentUser: User
    var currentPeople: MPeople?
    
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ListenerService.shared.removeRequestChatsListener()
        ListenerService.shared.removeActiveChatsListener()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupCollectionView()
        setupDataSource()
        loadSectionHedear()
        reloadDataSource(searchText: nil)
        setupListeners()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentPeople = UserDefaultsService.shared.getMpeople()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    private func setupListeners() {
        ListenerService.shared.addRequestChatsListener(delegate: self)
    }
    
    //MARK:  setupCollectionView
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds,
                                          collectionViewLayout: setupCompositionalLayout())
        
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .myWhiteColor()
        collectionView.delegate = self
  
        collectionView.register(ActiveChatsCell.self, forCellWithReuseIdentifier: ActiveChatsCell.reuseID)
        collectionView.register(NewChatsCell.self, forCellWithReuseIdentifier: NewChatsCell.reuseID)
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
        
        let grupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(0.2))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: grupSize,
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 15
        section.contentInsets = NSDirectionalEdgeInsets(top: 25,
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseID, for: indexPath) as? T else { fatalError("Can't dequeue cell type \(cellType)") }
        
        cell.configure(with: value)
        return cell
    }
    
    //MARK:  setupDataSource
    private func setupDataSource(){
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
                                         font: .avenirBold(size: 12),
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
    }
}


extension RequestsViewController: RequestChatListenerDelegate {
    //MARK: reloadRequestData
    func reloadData(changeType: TypeOfListenerChanges) {
        reloadDataSource()
    }
}

//MARK: CollectionViewDelegate
extension RequestsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = SectionsRequests(rawValue: indexPath.section) else { fatalError("Unknow section index")}
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { fatalError(DataSourceError.unknownChatIdentificator.localizedDescription)}
        guard let currentPeople = currentPeople else { fatalError("Current people is nil")}
        
        switch section {
        case .requestChats:
            let requestVC = GetRequestViewController(chatRequest: item, currentPeople: currentPeople)
            present(requestVC, animated: true, completion: nil)
        }
    }
}
