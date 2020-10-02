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
    var peopleNearby: [MPeople] = []
    var sortedPeopleNearby: [MPeople] {
        peopleNearby.sorted { p1, p2  in
            p1.advert < p2.advert
        }
    }
    var visibleIndexPath: IndexPath?
    var inactiveView = AdvertInactiveView(isHidden: true)
    var nameLabel = UILabel(labelText: "Name", textFont: .avenirBold(size: 38))
    var distanceLabel = UILabel(labelText: "0.00KM", textFont: .avenirBold(size: 16))
    var advertLabel = UILabel(labelText: "Test one more and more",
                              textFont: .avenirRegular(size: 16),
                              aligment: .center,
                              linesCount: 5)
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<SectionsPeople, MPeople>?
    
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
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8),
                                               heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                     subitems: [item])
        
    
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 40
        section.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                        leading: 40,
                                                        bottom: 0,
                                                        trailing: 40)
        
        section.visibleItemsInvalidationHandler = { [weak self]visibleItems, point, environment in

            self?.setDataForVisibleCell()
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
        
        setDataForVisibleCell()
    }
    //MARK:  reloadData
    func reloadData() {
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionsPeople,MPeople>()
        snapshot.appendSections([.main])
        snapshot.appendItems(sortedPeopleNearby, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: true)
        
        setDataForVisibleCell()
    }
}

//MARK:setDataForVisibleCell
extension PeopleViewController {
    
    private func setDataForVisibleCell()  {
        var visibleRect = CGRect()
        
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        
        //set only when index path change to new value
        if visibleIndexPath != indexPath {
            
            let item = dataSource?.itemIdentifier(for: indexPath)
            
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineHeightMultiple = 0.8
            paragraph.alignment = .center
            
            let attributes: [NSAttributedString.Key : Any] = [
                .paragraphStyle : paragraph
            ]
            
            advertLabel.attributedText = NSMutableAttributedString(string: item?.advert ?? "", attributes: attributes)
            nameLabel.text = item?.displayName
            distanceLabel.text = "0.00KM"
            
//            UIView.animate(withDuration: 0.2) {[weak self] in
//                self?.advertLabel.layer.opacity = 0
//                self?.nameLabel.layer.opacity = 0
//                self?.distanceLabel.layer.opacity = 0
//            } completion: {[weak self] isComplite in
//                if isComplite {
//                    self?.advertLabel.attributedText = NSMutableAttributedString(string: item?.advert ?? "", attributes: attributes)
//                    self?.nameLabel.text = item?.displayName
//                    self?.distanceLabel.text = "0.00KM"
//                    UIView.animate(withDuration: 0.5) {[weak self] in
//                        self?.advertLabel.layer.opacity = 1
//                        self?.nameLabel.layer.opacity = 1
//                        self?.distanceLabel.layer.opacity = 1
//                    }
//                }
//            }
            //set new current visible indexPath
            visibleIndexPath = indexPath
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
    
   
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        print(#function)
        
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
        print(indexPath)
    }
   
}

//MARK: setupConstraints
extension PeopleViewController {
    private func setupConstraints() {
    
        inactiveView.autoresizingMask = [.flexibleHeight, .flexibleWidth ]
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        advertLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        view.addSubview(nameLabel)
        view.addSubview(distanceLabel)
        view.addSubview(advertLabel)
        view.addSubview(inactiveView)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            nameLabel.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: -10),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            collectionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            
            distanceLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            distanceLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            
            advertLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            advertLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            advertLabel.topAnchor.constraint(equalTo: distanceLabel.bottomAnchor, constant: 5),
        ])
    }
}
