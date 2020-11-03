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


class ChatsViewController: UIViewController {
    
    var collectionView: UICollectionView?
    var dataSource: UICollectionViewDiffableDataSource<SectionsChats, MChat>?
    var currentPeople: MPeople
    weak var acceptChatDelegate: AcceptChatListenerDelegate?
    
    init(currentPeople: MPeople, acceptChatDelegate: AcceptChatListenerDelegate?) {
        self.currentPeople = currentPeople
        self.acceptChatDelegate = acceptChatDelegate
        
        super.init(nibName: nil, bundle: nil)
        
        setupListeners()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ListenerService.shared.removeAcceptChatsListener()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupCollectionView()
        setupDataSource()
        loadSectionHedear()
        reloadDataSource(searchText: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCurrentPeople()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //reloadDataSource(searchText: nil)
    }
    
    private func setupListeners() {
        acceptChatDelegate?.setupListener()
    }
    
    private func updateCurrentPeople() {
        if let people = UserDefaultsService.shared.getMpeople() {
            currentPeople = people
        }
    }
    
    //MARK:  setupNavigationController
    private func setupNavigationController(){
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backButtonTitle = ""
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.backgroundColor = .myWhiteColor()
        searchController.searchBar.barTintColor = .myWhiteColor()
        searchController.searchBar.placeholder = "Поиск по людям"
        searchController.searchBar.searchTextField.borderStyle = .roundedRect
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    //MARK:  setupCollectionView
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds,
                                          collectionViewLayout: setupCompositionalLayout(isEmptyActiveSection: false,
                                                                                         isEmptyNewSection: false))
        
        guard let collectionView = collectionView else { fatalError("CollectionView is nil")}
        
    
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .myWhiteColor()
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        collectionView.register(ActiveChatsCell.self, forCellWithReuseIdentifier: ActiveChatsCell.reuseID)
        collectionView.register(NewChatsCell.self, forCellWithReuseIdentifier: NewChatsCell.reuseID)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
    }
    
}

//MARK:  setupCompositionLayout
extension ChatsViewController {
    
    private func setupCompositionalLayout(isEmptyActiveSection: Bool, isEmptyNewSection: Bool) -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let section = SectionsChats(rawValue: sectionIndex) else { fatalError("Unknown section")}
            
            switch section {
            case .activeChats:
                return self.createActiveChatsLayout(isEmpty: isEmptyActiveSection)
            case .newChats:
                return self.createWaitingChatsLayout(isEmpty: isEmptyNewSection)
            }
        }
        print("layout")
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
    private func createActiveChatsLayout(isEmpty: Bool) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let grupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: isEmpty ? .absolute(0.0) : .fractionalWidth(1/5))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: grupSize,
                                                       subitems: [item])
        

        
        let section = NSCollectionLayoutSection(group: group)
        
        if !isEmpty {
            let sectionHeader = createSectionHeader()
            section.boundarySupplementaryItems = [sectionHeader]
        }
        
        section.interGroupSpacing = 15
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 20,
                                                        leading: 20,
                                                        bottom: 0,
                                                        trailing: 20)
        
        
        return section
    }
    
    //MARK:  createWaitingChatsLayout
    private func createWaitingChatsLayout(isEmpty: Bool) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                     leading: 0,
                                                     bottom: 0,
                                                     trailing: 0)
        
        let grupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/5),
                                              heightDimension: isEmpty ? .absolute(0.0) : .fractionalWidth(1/5))
        
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
        section.contentInsets = NSDirectionalEdgeInsets(top: 20,
                                                        leading: 20,
                                                        bottom: 15,
                                                        trailing: 20)
        return section
    }
}

//MARK:  DiffableDataSource
extension ChatsViewController {
    //MARK:  configure  cell
    private func configure<T: SelfConfiguringCell>(cellType: T.Type, value: MChat, indexPath: IndexPath) -> T {
        guard let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: cellType.reuseID, for: indexPath) as? T else { fatalError("Can't dequeue cell type \(cellType)") }
        
        cell.configure(with: value)
        return cell
    }
    
    //MARK:  setupDataSource
    private func setupDataSource(){
        guard let collectionView = collectionView else { fatalError("CollectionView is nil")}
        dataSource = UICollectionViewDiffableDataSource<SectionsChats, MChat>(
            collectionView: collectionView,
            cellProvider: { [weak self] (collectionView, indexPath, chat) -> UICollectionViewCell? in
                
                guard let section = SectionsChats(rawValue: indexPath.section) else {
                    fatalError("Unknown Section")
                }
                
                switch section {
                case .activeChats:
                    return self?.configure(cellType: ActiveChatsCell.self, value: chat, indexPath: indexPath)
                    
                case .newChats:
                    return self?.configure(cellType: NewChatsCell.self, value: chat, indexPath: indexPath)
                }
            })
    }
    
    //MARK:  supplementaryViewProvider
    private func loadSectionHedear() {
        
        dataSource?.supplementaryViewProvider = {
            [weak self] collectionView, kind, indexPath in
            guard let reuseSectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else { fatalError("Can't create new sectionHeader") }
            
            guard let section = SectionsChats(rawValue: indexPath.section) else { fatalError("Unknown section")}
            
            guard let itemsInSection = self?.collectionView?.numberOfItems(inSection: indexPath.section) else { fatalError("Can't get count of items")}
           
            reuseSectionHeader.configure(text: section.description(count: itemsInSection),
                                         font: .avenirRegular(size: 12),
                                         textColor: UIColor.myGrayColor())
            
        
            return reuseSectionHeader
        }
    }
}


extension ChatsViewController: AcceptChatCollectionViewDelegate {
    //MARK:  reloadDataSource
    func reloadDataSource(searchText: String?){
        print(#function)
        guard let sortedAcceptChats = acceptChatDelegate?.sortedAcceptChats else { fatalError("Can't get sorted accept chats")}
        let filtredAcceptChats = sortedAcceptChats.filter { acceptChat -> Bool in
            acceptChat.contains(element: searchText)
        }
        
        let newChats = filtredAcceptChats.filter { filtredAcceptChat -> Bool in
            filtredAcceptChat.isNewChat
        }
        
        let activeChats = filtredAcceptChats.filter { filtredAcceptChat -> Bool in
            !filtredAcceptChat.isNewChat
        }
        if let dataSource = dataSource {
            //for correct update cell data in collectionView
            print("1")
            var snapshot = dataSource.snapshot()
            snapshot.deleteAllItems()
            snapshot.appendSections([.newChats, .activeChats])
            snapshot.appendItems(newChats, toSection: .newChats)
            snapshot.appendItems(activeChats, toSection: .activeChats)
            dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
                self?.collectionView?.collectionViewLayout.invalidateLayout()
                self?.collectionView?.layoutIfNeeded()
                self?.collectionView?.setCollectionViewLayout(self?.setupCompositionalLayout(isEmptyActiveSection: activeChats.isEmpty,
                                                                                             isEmptyNewSection: newChats.isEmpty) ?? UICollectionViewFlowLayout(),
                                                              animated: false)
                DispatchQueue.global().async {
                    //if only one chat in collection, and this is update, need second renew, for correct update header (change new to active chat)
                    if filtredAcceptChats.count == 1 {
                        if var snapshot2 = self?.dataSource?.snapshot() {
                            snapshot2.deleteAllItems()
                            snapshot2.appendSections([.newChats, .activeChats])
                            snapshot2.appendItems(newChats, toSection: .newChats)
                            snapshot2.appendItems(activeChats, toSection: .activeChats)
                            self?.dataSource?.apply(snapshot2)
                        }
                    }
                }
            }

        } else {
            print("2")
            var snapshot = NSDiffableDataSourceSnapshot<SectionsChats,MChat>()
            snapshot.appendSections([.newChats,.activeChats])
            snapshot.appendItems(newChats, toSection: .newChats)
            snapshot.appendItems(activeChats, toSection: .activeChats)
            dataSource?.apply(snapshot, animatingDifferences: false, completion: { [weak self] in
                self?.collectionView?.collectionViewLayout.invalidateLayout()
                self?.collectionView?.layoutIfNeeded()
                self?.collectionView?.setCollectionViewLayout(self?.setupCompositionalLayout(isEmptyActiveSection: activeChats.isEmpty,
                                                                                isEmptyNewSection: newChats.isEmpty) ?? UICollectionViewFlowLayout(),
                                                       animated: false)
            })
        }
    }
    
    func updateForDeleteDataSource() {
       reloadDataSource(searchText: nil)
    }
    
    //MARK:  updateDataSource
    func updateDataSource(){
        reloadDataSource(searchText: nil)
    }
}


//MARK: UISearchBarDelegate
extension ChatsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadDataSource(searchText: searchText)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        reloadDataSource(searchText: nil)
    }
}

//MARK: CollectionViewDelegate
extension ChatsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = SectionsChats(rawValue: indexPath.section) else { fatalError("Unknow section index")}
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { fatalError(DataSourceError.unknownChatIdentificator.localizedDescription)}
        
        switch section {
        case .newChats:
            
            let chatVC = ChatViewController(people: currentPeople, chat: item, messageDelegate: MessagesDataProvider())
            navigationController?.pushViewController(chatVC, animated: true)
            
        case .activeChats:
            
            let chatVC = ChatViewController(people: currentPeople, chat: item, messageDelegate: MessagesDataProvider())
            navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}
