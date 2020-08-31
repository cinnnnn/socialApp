//
//  PeopleViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 05.07.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI

class PeopleViewController: UIViewController {
    
    
    var peopleNearby = Bundle.main.decode(type: [MPeople].self, from: "PeopleNearby.json")
    
    var collectionView: UICollectionView!
    
    var dataSource: UICollectionViewDiffableDataSource<SectionsPeople, MPeople>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupNavigationController()
        setupCollectionView()
        setupDiffebleDataSource()
        reloadData()
    }
    
      //MARK: - setupNavigationController
    private func setupNavigationController(){
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .systemBackground
        navigationItem.title = "Объявления"
        
    }
    
    //MARK: - setupCollectionView
    private func setupCollectionView() {
        
        collectionView = UICollectionView(frame: view.bounds,
                                          collectionViewLayout: setupCompositionLayout())
        
        collectionView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        collectionView.register(PeopleCell.self,
                                forCellWithReuseIdentifier: PeopleCell.reuseID)
        collectionView.register(SectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SectionHeader.reuseId)
    }
    
       //MARK: - setupMainSection
    private func setupMainSection() -> NSCollectionLayoutSection {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .estimated(200))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(200))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize,
                                                     subitems: [item])
        
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 25,
                                                        leading: 0,
                                                        bottom: 0,
                                                        trailing: 0)
        return section
    }
    
       //MARK: - setupCompositionLayout
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
    
    
    //MARK:  -pressLikeButton()
    @objc private func pressLikeButton() {
       
        reloadData()
    }
    
      //MARK: - configureCell
    private func configureCell<T:PeopleConfigurationCell>(cellType: T.Type, value: MPeople, indexPath: IndexPath) -> T {
        
        guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseID, for: indexPath) as? T else { fatalError("Can't dequeue cell type \(cellType)")}
        
        cell.configure(with: value)
        cell.likeButton.addTarget(self, action: #selector(pressLikeButton), for: .touchUpInside)
        cell.delegate = self
        
        
        return cell
    }
    
     //MARK: - setupDiffebleDataSource
    private func setupDiffebleDataSource() {
        
        dataSource = UICollectionViewDiffableDataSource<SectionsPeople,MPeople>(
            collectionView: collectionView,
            cellProvider: { [weak self] (collectionView, indexPath, people) -> UICollectionViewCell? in
                guard let section = SectionsPeople(rawValue: indexPath.section) else { fatalError("Unknown people section")}
                
                switch section {
                case .main:
                    return self?.configureCell(cellType: PeopleCell.self,
                                               value: people,
                                               indexPath: indexPath)
                }
        })
        
    }
    
    //MARK: - reloadData()
    private func reloadData() {
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionsPeople,MPeople>()
        snapshot.appendSections([.main])
        snapshot.appendItems(peopleNearby, toSection: .main)
        
        dataSource?.apply(snapshot, animatingDifferences: true)
        
    }
}

    //MARK: - PeopleCellDelegate()

extension PeopleViewController: PeopleCellDelegate {
    func likeTupped(user: MPeople) {
        
       let indexUser = peopleNearby.firstIndex { people -> Bool in
            people.id == user.id
        }
        
        guard let index = indexUser else { fatalError("Unknown index of MPeople")}
        peopleNearby[index] = user
    }

}

//MARK:- SwiftUI

struct PeopleViewControllerProvider: PreviewProvider {
    
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
