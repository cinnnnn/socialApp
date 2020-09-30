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
    var inactiveView = AdvertInactiveView(isHidden: true)
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<SectionsPeople, MPeople>?
    var currentUser: User!
    var currentPeople: MPeople?
    
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
        
        setupCollectionView()
        setupDiffebleDataSource()
        setup()
        setupConstraints()

        ListenerService.shared.addPeopleListener(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkActiveAdvert()
    }
    
    //MARK:  setup
    private func setup() {
        
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.backgroundColor = .systemBackground
        navigationItem.title = "Объявления"
        
        view.backgroundColor = .systemBackground
        
    }
    
    //MARK: checkActiveAdvert
    private func checkActiveAdvert() {
        currentPeople = UserDefaultsService.shared.getMpeople()
        if let state = currentPeople?.isActive {
            inactiveView.isHidden = state
            inactiveView.goToConfigButton.addTarget(self, action: #selector(touchGoToSetup), for: .touchUpInside)
        }
    }
    
    //MARK: setupCollectionView
    private func setupCollectionView() {
        
        collectionView = UICollectionView(frame: view.bounds,
                                          collectionViewLayout: setupCompositionLayout())
        
        collectionView.backgroundColor = nil
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = false
        
        collectionView.register(PeopleCell.self,
                                forCellWithReuseIdentifier: PeopleCell.reuseID)
        collectionView.register(SectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SectionHeader.reuseId)
    }
    
    //MARK: setupMainSection
    private func setupMainSection() -> NSCollectionLayoutSection {
//        let statusBarHeight = UIApplication.statusBarHeight
//        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
//        let sectionHeight = view.frame.height - statusBarHeight - tabBarHeight
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                               heightDimension: .fractionalHeight(0.9))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                     subitems: [item])
        
    
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 12.5
        section.contentInsets = NSDirectionalEdgeInsets(top: 12.5,
                                                        leading: 12.5,
                                                        bottom: 12.5,
                                                        trailing: 12.5)
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
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellType.reuseID, for: indexPath) as? T else { fatalError("Can't dequeue cell type \(cellType)")}
        
        cell.configure(with: value)
      //  cell.likeButton.addTarget(self, action: #selector(pressLikeButton), for: .touchUpInside)
      //  cell.delegate = self
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

//MARK:  UICollectionViewDelegate
extension PeopleViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = dataSource?.itemIdentifier(for: indexPath) else { return }
        guard let currentPeople = currentPeople else { fatalError("Current people is nil") }
        let sendRequestVC = SendRequestViewController(requestForPeople: user, from: currentPeople)
        present(sendRequestVC, animated: true, completion: nil)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()

            visibleRect.origin = collectionView.contentOffset
            visibleRect.size = collectionView.bounds.size

            let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        print(indexPath)
    }
   
}
//MARK:  PeopleCellDelegate
extension PeopleViewController: PeopleCellDelegate {
    func likeTupped(user: MPeople) {
        
        let indexUser = peopleNearby.firstIndex { people -> Bool in
            people.senderId == user.senderId
        }
        
        guard let index = indexUser else { fatalError("Unknown index of MPeople")}
        peopleNearby[index] = user
    }
}

extension PeopleViewController {
    private func setupConstraints() {
    
        inactiveView.autoresizingMask = [.flexibleHeight, .flexibleWidth ]
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        view.addSubview(inactiveView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
