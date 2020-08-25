//
//  ListViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 05.07.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI


class ListViewController: UIViewController {
    
    var collectionView: UICollectionView!
    
    enum Sections: Int, CaseIterable {
        case waitingChats
        case activeChats
        
        func description() -> String {
            switch self {
            case .waitingChats:
                return "Запросы"
            case .activeChats:
                return "Активные чаты"
            }
        }
    }
    
    let activeChats = Bundle.main.decode(type: [MChat].self, from: "activeChats.json")
    let waitingChats = Bundle.main.decode(type: [MChat].self, from: "waitingChats.json")
    
    var dataSource: UICollectionViewDiffableDataSource<Sections, MChat>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupNavigationController()
        setupCollectionView()
        setupDataSource()
        reloadData()
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds,
                                          collectionViewLayout: setupCompositionalLayout())
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .myBackgroundColor()
        
        view.addSubview(collectionView)
        collectionView.register(ActiveChatsCell.self, forCellWithReuseIdentifier: ActiveChatsCell.reuseID)
        collectionView.register(WaitingChatsCell.self, forCellWithReuseIdentifier: WaitingChatsCell.reuseID)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
    }
    

    //MARK: - setupNavigationController
    private func setupNavigationController(){
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .myBackgroundColor()
        navigationController?.navigationBar.barTintColor = .myBackgroundColor()
 
        navigationItem.title = "Chats"
        
        let searchController = UISearchController(searchResultsController: nil)
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
    }
    
   
}

//MARK: - setupCompositionLayout
extension ListViewController {
    
    private func setupCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let section = Sections(rawValue: sectionIndex) else { fatalError("Unknown section")}
            
            switch section {
            case .activeChats:
                return self.createActiveChatsLayout()
            case .waitingChats:
                return self.createWaitingChatsLayout()
            }
            
        }
        
        return layout
    }
    
        //MARK: - createSectionHeader
    private func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        
        let sectionSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                 heightDimension: .estimated(1))
        
        let item = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: sectionSize,
                                                                        elementKind: UICollectionView.elementKindSectionHeader,
                                                                        alignment: .top)
        
        return item
    }
    
    //MARK: - createActiveChatsLayout
    private func createActiveChatsLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let grupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .absolute(80))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: grupSize,
                                                     subitems: [item])
        
       
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                      leading: 0,
                                                      bottom: 0,
                                                      trailing: 0)
        
        
        let section = NSCollectionLayoutSection(group: group)
        
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        
        section.interGroupSpacing = 16

        section.contentInsets = NSDirectionalEdgeInsets(top: 11,
                                                        leading: 25,
                                                        bottom: 0,
                                                        trailing: 25)
        
        return section
    }
    
    //MARK: - createWaitingChatsLayout
    private func createWaitingChatsLayout() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                     leading: 0,
                                                     bottom: 0,
                                                     trailing: 0)
        
        let grupSize = NSCollectionLayoutSize(widthDimension: .absolute(80),
                                              heightDimension: .absolute(80))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: grupSize,
                                                       subitems: [item])
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                      leading: 0,
                                                      bottom: 0,
                                                      trailing: 0)
        
        let section = NSCollectionLayoutSection(group: group)
        
        let sectionHeader = createSectionHeader()
        section.boundarySupplementaryItems = [sectionHeader]
        
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 25
        section.contentInsets = NSDirectionalEdgeInsets(top: 11,
                                                        leading: 25,
                                                        bottom: 10,
                                                        trailing: 25)
        
        return section
    }
}
//MARK: - DiffableDataSource
extension ListViewController {
    
    private func configure<T: SelfConfiguringCell>(cellType: T.Type, value: MChat, indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseID, for: indexPath) as? T else { fatalError("Can't dequeue cell type \(cellType)") }
        
        cell.configure(with: value)
        return cell
    }
    
    
    private func setupDataSource(){
        dataSource = UICollectionViewDiffableDataSource<Sections, MChat>(collectionView: collectionView,
            cellProvider: { [weak self] (collectionView, indexPath, chat) -> UICollectionViewCell? in
               
                guard let section = Sections(rawValue: indexPath.section) else {
                    fatalError("Unknown Section")
                }
                
                switch section {
                case .activeChats:
                    
                    return self?.configure(cellType: ActiveChatsCell.self, value: chat, indexPath: indexPath)
                    
                case .waitingChats:
                    
                    return self?.configure(cellType: WaitingChatsCell.self, value: chat, indexPath: indexPath)
                }
        })
        
        dataSource?.supplementaryViewProvider = {
            collectionView, kind, indexPath in
            guard let reuseSectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else { fatalError("Can't create new sectionHeader") }
            
            guard let section = Sections(rawValue: indexPath.section) else { fatalError("Unknown section")}
            
            reuseSectionHeader.configure(text: section.description(),
                                         font: UIFont.boldSystemFont(ofSize: 11),
                                         textColor: UIColor.myHeaderColor())
           
            return reuseSectionHeader
        }
    }
    
    
    //MARK: - reloadData
    private func reloadData(){
             
             var snapshot = NSDiffableDataSourceSnapshot<Sections,MChat>()
             snapshot.appendSections([.waitingChats, .activeChats])
             snapshot.appendItems(activeChats, toSection: .activeChats)
             snapshot.appendItems(waitingChats, toSection: .waitingChats)
             
             dataSource?.apply(snapshot, animatingDifferences: true)
         }
}

//MARK: -UISearchBarDelegate
extension ListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
}


//MARK:- SwiftUI

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
