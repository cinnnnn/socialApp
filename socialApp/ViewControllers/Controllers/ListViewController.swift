//
//  ListViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 05.07.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI

struct MChat: Hashable {
    var userName: String
    var userImage: UIImage
    var lastMessage: String
    var id = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MChat, rhs: MChat) -> Bool {
        return lhs.id == rhs.id
    }
}

class ListViewController: UIViewController {
    
    var collectionView: UICollectionView!
    
    enum Sections: Int, CaseIterable {
        case activeChats
    }
    
    let activeChats:[MChat] = [
        MChat(userName: "Human1",
              userImage: #imageLiteral(resourceName: "avatar6"),
              lastMessage: "Hello 1"),
        MChat(userName: "Human2",
              userImage: #imageLiteral(resourceName: "avatar5"),
              lastMessage: "by"),
        MChat(userName: "Human3",
              userImage: #imageLiteral(resourceName: "avatar4"),
              lastMessage: "how are u")
    ]
    
    var dataSource: UICollectionViewDiffableDataSource<Sections, MChat>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupCollectionView()
        setupNavigationController()
        setupDataSource()
        reloadData()
    }
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds,
                                          collectionViewLayout: setupCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .myBackgroundColor()
        
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CellID")
    }
    
    private func setupDataSource(){
        dataSource = UICollectionViewDiffableDataSource<Sections, MChat>(collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, chat) -> UICollectionViewCell? in
                guard let section = Sections(rawValue: indexPath.section) else {
                    fatalError("Unknow Section")
                }
                
                switch section {
                    
                case .activeChats:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellID", for: indexPath)
                    cell.backgroundColor = .systemBlue
                    return cell
                }
        })
    }
    
    private func reloadData(){
        
        var snapshot = NSDiffableDataSourceSnapshot<Sections,MChat>()
        snapshot.appendSections([.activeChats])
        snapshot.appendItems(activeChats, toSection: .activeChats)
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func setupCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(1))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let grupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .absolute(80))
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: grupSize,
                                                         subitems: [item])
            
            group.contentInsets = NSDirectionalEdgeInsets(top: 8,
                                                          leading: 0,
                                                          bottom: 0,
                                                          trailing: 0)
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 16,
                                                            leading: 25,
                                                            bottom: 0,
                                                            trailing: 25)
            
            return section
        }
        return layout
    }
    
    
    
    private func setupNavigationController(){
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .myBackgroundColor()
 
        navigationItem.title = "Chats"
        
        let searchController = UISearchController(searchResultsController: nil)
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
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
