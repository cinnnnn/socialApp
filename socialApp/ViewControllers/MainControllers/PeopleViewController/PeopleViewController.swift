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
    
    var currentUser: User!
    var currentPeople: MPeople?
    weak var requestDelegate: RequestChatDelegate?
    var peopleNearby: [MPeople] = []
    var sortedPeopleNearby: [MPeople] {
        peopleNearby.sorted { p1, p2  in
            p1.distance < p2.distance
        }
    }
    var visibleIndexPath: IndexPath?
    var inactiveView = AdvertInactiveView(isHidden: true)
    var nameLabel = UILabel(labelText: "Name", textFont: .avenirBold(size: 38))
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<SectionsPeople, MPeople>?
    
    init(currentUser: User, requestDelegate: RequestChatDelegate) {
        self.requestDelegate = requestDelegate
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkActiveAdvert()
    }
    
    //MARK:  setup
    private func setup() {
        ListenerService.shared.addPeopleListener(delegate: self)
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
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                               heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                     subitems: [item])
        
    
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 40
        section.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                        leading: 20,
                                                        bottom: 0,
                                                        trailing: 20)
        
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, point, environment in

            self?.setDataForVisibleCell()
            self?.setUIForVisivleCells(items: visibleItems, point: point, enviroment: environment)
            
        }
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
    private  func configureCell(value: MPeople, indexPath: IndexPath) -> PeopleCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PeopleCell.reuseID, for: indexPath) as? PeopleCell else { fatalError("Can't dequeue cell type PeopleCell")}
        cell.likeDislikeDelegate = self
        cell.configure(with: value) {
            cell.layoutIfNeeded()
        }
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
                    return self?.configureCell(value: people,
                                               indexPath: indexPath)
                }
        })
    }
    
    //MARK:  updateData
    func updateData() {
        guard var snapshot = dataSource?.snapshot() else { return }
        snapshot.appendItems(sortedPeopleNearby, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: true)
        
        setDataForVisibleCell(firstLoad: true)
    }
    
    //MARK:  reloadData
    func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionsPeople,MPeople>()
        snapshot.appendSections([.main])
        snapshot.appendItems(sortedPeopleNearby, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: true)
        
        setDataForVisibleCell(firstLoad: true)
    }
}

//MARK:setDataForVisibleCell
extension PeopleViewController {
    private func setDataForVisibleCell(firstLoad: Bool = false)  {
        var visibleRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        
        //set only when index path change to new value
        if visibleIndexPath != indexPath || firstLoad {
            guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
            nameLabel.text = item.displayName
            //set new current visible indexPath
            visibleIndexPath = indexPath
        }
    }
}

//MARK: setUIForVisivleCells
extension PeopleViewController {
    private func setUIForVisivleCells(items: [NSCollectionLayoutVisibleItem], point: CGPoint, enviroment: NSCollectionLayoutEnvironment) {
        items.forEach { visibleItem in
            let distanceFromCenter = abs((visibleItem.frame.midX - point.x) - enviroment.container.contentSize.width / 2.0)
            let minScale: CGFloat = 0.5
            let maxScale: CGFloat = 1
            let scale = max(maxScale - (distanceFromCenter / enviroment.container.contentSize.width / 2), minScale)
            visibleItem.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
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
}

//MARK: likeDislikeDelegate
extension PeopleViewController: LikeDislikeDelegate {
    
     func likePeople(people: MPeople) {
        guard let currentPeople = currentPeople else { return }
        FirestoreService.shared.likePeople(currentUser: currentPeople,
                                           likeUser: people,
                                           requestChats: requestDelegate?.requestChats ?? []) { result in
            switch result {
            
            case .success(let chat):
                print(chat.friendUserName)
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
     func dislikePeople(people: MPeople) {
        guard let currentPeople = currentPeople else { return }
        FirestoreService.shared.dislikePeople(currentUser: currentPeople,
                                              forUser: people) { result in
            switch result {
            
            case .success(let shortPeople):
                print("dislike \(shortPeople.userName)")
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
      
    }
}

//MARK: setupConstraints
extension PeopleViewController {
    private func setupConstraints() {
    
        inactiveView.autoresizingMask = [.flexibleHeight, .flexibleWidth ]
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
       
        
        view.addSubview(collectionView)
        view.addSubview(nameLabel)
       
        view.addSubview(inactiveView)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
