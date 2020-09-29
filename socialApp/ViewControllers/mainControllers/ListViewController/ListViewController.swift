//
//  ListViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 05.07.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI
import FirebaseAuth


class ListViewController: UIViewController {
    
    var collectionView: UICollectionView!
    var activeChats: [MChat] = []
    var requestChats: [MChat] = []
    var sortedActiveChats: [MChat] {
        activeChats.sorted {
            $0.date > $1.date
        }
    }
    var sortedRequestChats: [MChat] {
        requestChats.sorted {
            $0.date > $1.date
        }
    }
    var previusStateRequestSectionIsEmpty = true
    
    var dataSource: UICollectionViewDiffableDataSource<SectionsChats, MChat>?
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
        
        setupNavigationController()
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
        ListenerService.shared.addActiveChatsListener(delegate: self)
    }
    
    //MARK:  setupCollectionView
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds,
                                          collectionViewLayout: setupCompositionalLayout(isEmptyRequestSection: true))
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        collectionView.register(ActiveChatsCell.self, forCellWithReuseIdentifier: ActiveChatsCell.reuseID)
        collectionView.register(RequestChatsCell.self, forCellWithReuseIdentifier: RequestChatsCell.reuseID)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
    }
    
    
    //MARK:  setupNavigationController
    private func setupNavigationController(){
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .systemBackground
        navigationController?.navigationBar.barTintColor = .systemBackground
        
        navigationItem.title = "Чаты"
        
        let searchController = UISearchController(searchResultsController: nil)
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Поиск по людям"
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}

//MARK:  setupCompositionLayout
extension ListViewController {
    
    private func setupCompositionalLayout(isEmptyRequestSection: Bool) -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let section = SectionsChats(rawValue: sectionIndex) else { fatalError("Unknown section")}
   
            switch section {
            case .activeChats:
                return self.createActiveChatsLayout()
            case .requestChats:
                return self.createWaitingChatsLayout(isEmpty: isEmptyRequestSection)
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
    
    //MARK:  createActiveChatsLayout
    private func createActiveChatsLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let grupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalWidth(1/6))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: grupSize,
                                                       subitems: [item])
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                      leading: 0,
                                                      bottom: 0,
                                                      trailing: 0)
        
        
        let section = NSCollectionLayoutSection(group: group)
        let sectionHeader = createSectionHeader()
        
        section.boundarySupplementaryItems = [sectionHeader]
        section.interGroupSpacing = 25
        section.contentInsets = NSDirectionalEdgeInsets(top: 25,
                                                        leading: 16,
                                                        bottom: 0,
                                                        trailing: 16)
        
        
        return section
    }
    
    //MARK:  createWaitingChatsLayout
    private func createWaitingChatsLayout(isEmpty: Bool ) -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                     leading: 0,
                                                     bottom: 0,
                                                     trailing: 0)
        
        let grupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/5),
                                              heightDimension: isEmpty ? .absolute(0) : .fractionalWidth(1/5))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: grupSize,
                                                       subitems: [item])
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                      leading: 0,
                                                      bottom: 0,
                                                      trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        
        if !isEmpty {
            let sectionHeader = createSectionHeader()
            section.boundarySupplementaryItems = [sectionHeader]
        }
        
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 15
        section.contentInsets = NSDirectionalEdgeInsets(top: 8,
                                                        leading: 16,
                                                        bottom: 8,
                                                        trailing: 16)
        return section
    }
}

//MARK:  DiffableDataSource
extension ListViewController {
    
    //MARK:  configure  cell
    private func configure<T: SelfConfiguringCell>(cellType: T.Type, value: MChat, indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseID, for: indexPath) as? T else { fatalError("Can't dequeue cell type \(cellType)") }
        
        cell.configure(with: value)
        return cell
    }
    
    //MARK:  setupDataSource
    private func setupDataSource(){
        dataSource = UICollectionViewDiffableDataSource<SectionsChats, MChat>(collectionView: collectionView,
                                                                              cellProvider: { [weak self] (collectionView, indexPath, chat) -> UICollectionViewCell? in
                                                                                
                                                                                
                                                                                guard let section = SectionsChats(rawValue: indexPath.section) else {
                                                                                    fatalError("Unknown Section")
                                                                                }
                                                                                
                                                                                switch section {
                                                                                case .activeChats:
                                                                                    return self?.configure(cellType: ActiveChatsCell.self, value: chat, indexPath: indexPath)
                                                                                    
                                                                                case .requestChats:
                                                                                    return self?.configure(cellType: RequestChatsCell.self, value: chat, indexPath: indexPath)
                                                                                }
                                                                              })
    }
    //MARK:  supplementaryViewProvider
    private func loadSectionHedear() {
        dataSource?.supplementaryViewProvider = {
            collectionView, kind, indexPath in
            guard let reuseSectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else { fatalError("Can't create new sectionHeader") }
            
            guard let section = SectionsChats(rawValue: indexPath.section) else { fatalError("Unknown section")}
            
            guard let itemsCount = self.dataSource?.snapshot().numberOfItems(inSection: section) else { fatalError("Unknow items count in section")}
            
            reuseSectionHeader.configure(text: section.description(count: itemsCount),
                                         font: UIFont.boldSystemFont(ofSize: 11),
                                         textColor: UIColor.myGrayColor())
            
            return reuseSectionHeader
        }
        
    }
    
    //MARK:  reloadData
    private func reloadDataSource(searchText: String?){

        let filtredChats = sortedActiveChats.filter { activeChat -> Bool in
            activeChat.contains(element: searchText)
        }

        var snapshot = NSDiffableDataSourceSnapshot<SectionsChats,MChat>()
        snapshot.appendSections([.requestChats,.activeChats])
        snapshot.appendItems(sortedRequestChats, toSection: .requestChats)
        snapshot.appendItems(filtredChats, toSection: .activeChats)
        dataSource?.apply(snapshot, animatingDifferences: true)
        
        updateHeader()
    }
    
    //MARK:  updateHeader
    private func updateHeader() {
        guard var snapshot = dataSource?.snapshot() else { fatalError("Snapshot not exist")}
        let activeSection = snapshot.sectionIdentifiers
        snapshot.reloadSections(activeSection)
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
}


extension ListViewController: RequestChatListenerDelegate, ActiveChatListenerDelegate {
    
    //MARK: reloadRequestData
    func reloadData(changeType: TypeOfListenerChanges) {
        
        
        switch changeType {
        
        case .addOrDelete:
            if sortedRequestChats.isEmpty  {
                collectionView.setCollectionViewLayout(setupCompositionalLayout(isEmptyRequestSection: true),
                                                       animated: false) {[weak self] finished in
                    if finished {
                        self?.reloadDataSource(searchText: nil)
                        self?.previusStateRequestSectionIsEmpty = true
                    }
                }
            } else {
                //if previous state empty, but now have request -> change Layout
                if previusStateRequestSectionIsEmpty {
                    collectionView.setCollectionViewLayout(setupCompositionalLayout(isEmptyRequestSection: false),
                                                           animated: false) {[weak self] finished in
                        if finished {
                            self?.reloadDataSource(searchText: nil)
                            self?.previusStateRequestSectionIsEmpty = false
                        }
                    }
                } else {
                    //previous state request section not empty, simple reload dataSource
                    reloadDataSource(searchText: nil)
                }
            }

        case .update:
            //for correct update cell data in collectionView
            guard var snapshot = dataSource?.snapshot() else { fatalError("Cant get snapshot")}
            snapshot.appendItems(sortedActiveChats, toSection: .activeChats)
            dataSource?.apply(snapshot, animatingDifferences: false)
        }
    }
}

//MARK: UISearchBarDelegate
extension ListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadDataSource(searchText: searchText)
    }
}

//MARK: CollectionViewDelegate
extension ListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = SectionsChats(rawValue: indexPath.section) else { fatalError("Unknow section index")}
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { fatalError(DataSourceError.unknownChatIdentificator.localizedDescription)}
        guard let currentPeople = currentPeople else { fatalError("Current people is nil")}
        
        switch section {
        case .requestChats:
            
            let requestVC = GetRequestViewController(chatRequest: item, currentPeople: currentPeople)
            present(requestVC, animated: true, completion: nil)
        case .activeChats:
            
            let chatVC = ChatsViewController(user: currentPeople, chat: item)
            navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}
//MARK: SwiftUI

struct ListViewControllerProvider: PreviewProvider {
    
    static var previews: some View {
        ContenerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContenerView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: Context) -> MainTabBarController {
            MainTabBarController()
        }
        
        func updateUIViewController(_ uiViewController: MainTabBarController, context: Context) {
            
        }
    }
}
