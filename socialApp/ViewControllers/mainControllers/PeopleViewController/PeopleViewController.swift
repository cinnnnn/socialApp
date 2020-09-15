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
    
    var peopleNearby: [MPeople] = []
    var sortedPeopleNearby: [MPeople] {
        peopleNearby.sorted { p1, p2  in
            p1.advert < p2.advert
        }
    }
    var peopleListner: ListenerRegistration?
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<SectionsPeople, MPeople>?
    var currentUser: User!
    
    init(currentUser: User) {
        self.currentUser = currentUser
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        peopleListner?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNavigationController()
        setupCollectionView()
        setupDiffebleDataSource()
        setupListener()
        
    }
    //MARK: - setup
    private func setup() {
        view.backgroundColor = .systemBackground
        
       
    }
      //MARK: - setupNavigationController
    private func setupNavigationController(){
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .systemBackground
        navigationItem.title = "Объявления"
        
    }
    
     //MARK: - setupListener
    private func setupListener() {
        
        let db = Firestore.firestore()
        var userRef: CollectionReference {
            db.collection("users")
        }
        peopleListner = userRef.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else { fatalError("Cant get snapshot") }
            
            snapshot.documentChanges.forEach {[weak self] changes in
                guard let user = MPeople(documentSnap: changes.document) else { return }
                guard let people = self?.peopleNearby else { return }
                switch changes.type {
                    
                case .added:
                    guard !people.contains(user) else { return }
                    guard user.id != self?.currentUser?.uid else { return }
                    self?.peopleNearby.append(user)
                    self?.reloadData()
                    
                case .modified:
                    guard let index = people.firstIndex(of: user) else { return }
                    self?.peopleNearby[index] = user
                    self?.updateData()
                  
                case .removed:
                    guard let index = people.firstIndex(of: user) else { return }
                    self?.peopleNearby.remove(at: index)
                    self?.reloadData()
                }
            }
        }
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
     //MARK: - deleteData
    private func deleteData(people: [MPeople]) {
    
        guard var snapshot = dataSource?.snapshot() else { return }
        snapshot.deleteItems(people)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    //MARK: - updateData
    private func updateData() {
    
        guard var snapshot = dataSource?.snapshot() else { return }
        
        snapshot.appendItems(sortedPeopleNearby, toSection: .main)
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    //MARK: - reloadData
    private func reloadData() {
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionsPeople,MPeople>()
        snapshot.appendSections([.main])
        snapshot.appendItems(sortedPeopleNearby, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}

//MARK:  - objc
extension PeopleViewController {

    @objc private func pressLikeButton() {
        reloadData()
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
