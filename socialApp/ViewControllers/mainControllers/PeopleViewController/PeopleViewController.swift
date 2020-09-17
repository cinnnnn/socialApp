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

class PeopleViewController: UIViewController, PeopleListenerDelegate {
    
    var peopleNearby: [MPeople] = []
    var sortedPeopleNearby: [MPeople] {
        peopleNearby.sorted { p1, p2  in
            p1.advert < p2.advert
        }
    }
    var inactiveView:AdvertInactiveView?
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
        ListenerService.shared.removePeopleListener()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupNavigationController()
        setupCollectionView()
        setupDiffebleDataSource()
        setupButtonTarget()
        setupConstraint()
        ListenerService.shared.addPeopleListener(delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkActiveAdvert()
    }
    
    //MARK:  setup
    private func setup() {
        view.backgroundColor = .systemBackground
        inactiveView = AdvertInactiveView(frame: view.bounds, isHidden: true)
    }
    
    //MARK: setupButtonTarget
    private func setupButtonTarget() {
        inactiveView?.goToConfigButton.addTarget(self, action: #selector(touchGoToSetup), for: .touchUpInside)
    }
    
    //MARK: checkActiveAdvert
    private func checkActiveAdvert() {
        
        FirestoreService.shared.getUserData(user: currentUser) {[weak self] result in
            switch result {
                
            case .success(let people):
                self?.inactiveView?.isHidden = people.isActive
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
    //MARK:  setupNavigationController
    private func setupNavigationController(){
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .systemBackground
        navigationItem.title = "Объявления"
    }
    
    //MARK: setupCollectionView
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
    
    //MARK: setupMainSection
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
    private func configureCell<T:PeopleConfigurationCell>(cellType: T.Type, value: MPeople, indexPath: IndexPath) -> T {
        
        guard var cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseID, for: indexPath) as? T else { fatalError("Can't dequeue cell type \(cellType)")}
        
        cell.configure(with: value)
        cell.likeButton.addTarget(self, action: #selector(pressLikeButton), for: .touchUpInside)
        cell.delegate = self
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
                    return self?.configureCell(cellType: PeopleCell.self,
                                               value: people,
                                               indexPath: indexPath)
                }
        })
    }

    //MARK:  updateData
    func updateData() {
        
        guard var snapshot = dataSource?.snapshot() else { return }
        snapshot.appendItems(sortedPeopleNearby, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    //MARK:  reloadData
    func reloadData() {
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionsPeople,MPeople>()
        snapshot.appendSections([.main])
        snapshot.appendItems(sortedPeopleNearby, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}

//MARK:  objc
extension PeopleViewController {
    
    @objc private func pressLikeButton() {
        reloadData()
    }
    
    @objc private func touchGoToSetup() {
        tabBarController?.selectedIndex = 0
    }
}
//MARK:  PeopleCellDelegate()
extension PeopleViewController: PeopleCellDelegate {
    func likeTupped(user: MPeople) {
        
        let indexUser = peopleNearby.firstIndex { people -> Bool in
            people.id == user.id
        }
        
        guard let index = indexUser else { fatalError("Unknown index of MPeople")}
        peopleNearby[index] = user
    }
    
}

extension PeopleViewController {
    
    private func setupConstraint(){
        
        guard let inactiveView = inactiveView else { fatalError("Advert view не инициализированно")}
        
        view.addSubview(inactiveView)
        
        inactiveView.autoresizingMask = [.flexibleHeight, .flexibleWidth ]
        
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
