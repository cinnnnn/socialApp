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

class PeopleViewController: UIViewController, UICollectionViewDelegate {
    
    var currentPeople: MPeople
    weak var peopleDelegate: PeopleListenerDelegate?
    weak var requestChatDelegate: RequestChatListenerDelegate?
    weak var likeDislikeDelegate: LikeDislikeListenerDelegate?
    weak var acceptChatDelegate: AcceptChatListenerDelegate?
    weak var reportDelegate: ReportsListnerDelegate?
    
    private var visibleIndexPath: IndexPath?
   
    private var emptyView = EmptyView(imageName: "empty",
                                      header: MLabels.emptyNearbyPeopleHeader.rawValue,
                                      text: MLabels.emptyNearbyPeopleText.rawValue,
                                      buttonText: MLabels.emptyNearbyPeopleButton.rawValue,
                                      delegate: self,
                                      selector: #selector(changeSearchTapped))
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<SectionsPeople, MPeople>?

    init(currentPeople: MPeople,
         peopleDelegate: PeopleListenerDelegate?,
         requestChatDelegate: RequestChatListenerDelegate?,
         likeDislikeDelegate: LikeDislikeListenerDelegate?,
         acceptChatDelegate: AcceptChatListenerDelegate?,
         reportDelegate: ReportsListnerDelegate?) {
        
        self.peopleDelegate = peopleDelegate
        self.requestChatDelegate = requestChatDelegate
        self.likeDislikeDelegate = likeDislikeDelegate
        self.acceptChatDelegate = acceptChatDelegate
        self.currentPeople = currentPeople
        self.reportDelegate = reportDelegate
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupDiffebleDataSource()
        setupConstraints()
        setup()
        setupNotification()
        getPeople()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        updateCurrentPeople()
    }
    
    
    //MARK:  setup VC
    private func setup() {
        view.backgroundColor = .myWhiteColor()
        navigationItem.backButtonTitle = ""
    }
    
    private func setupNotification() {
        NotificationCenter.addObsorverToCurrentUser(observer: self, selector: #selector(updateCurrentPeople))
        NotificationCenter.addObsorverToPremiumUpdate(observer: self, selector: #selector(premiumIsUpdated))
    }
    
    //MARK: getPeople
    private func getPeople() {
        guard let likeDislikeDelegate = likeDislikeDelegate else { fatalError("Can't get likeDislikeDelegate")}
        guard let acceptChatDelegate = acceptChatDelegate else { fatalError("Can't get acceptChatDelegate")}
        guard let reportDelegate = reportDelegate else { fatalError("Can't get reportDelegate")}
        
        peopleDelegate?.getPeople(currentPeople: currentPeople,
                                  likeDislikeDelegate: likeDislikeDelegate,
                                  acceptChatsDelegate: acceptChatDelegate,
                                  reportsDelegate: reportDelegate,
                                  complition: { result in
                                    switch result {
                                    case .success(_):
                                        break
                                    case .failure(let error):
                                        fatalError(error.localizedDescription)
                                    }
                                  })
    }
    
    
    //MARK: setupCollectionView
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds,
                                          collectionViewLayout: setupCompositionLayout())
        
        collectionView.backgroundColor = nil
        collectionView.delegate = self
        collectionView.isScrollEnabled = false
        collectionView.isPagingEnabled = false
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

            self?.setUIForVisibleCells(items: visibleItems, point: point, enviroment: environment)
            
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

    //MARK: setupDataSource
    private func setupDiffebleDataSource() {
        dataSource = UICollectionViewDiffableDataSource<SectionsPeople,MPeople>(
            collectionView: collectionView,
            cellProvider: { [weak self] (collectionView, indexPath, people) -> UICollectionViewCell? in
                guard let section = SectionsPeople(rawValue: indexPath.section) else { fatalError("Unknown people section")}
                
                switch section {
                case .main:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PeopleCell.reuseID, for: indexPath) as? PeopleCell else { fatalError("Can't dequeue cell type PeopleCell")}
                    if let currentPeople = self?.currentPeople {
                        cell.configure(with: people, currentPeople: currentPeople, buttonDelegate: self)
                        {
                            cell.setNeedsLayout()
                        }
                    }
                    return cell
                }
        })
    }
}

//MARK: setUIForVisivleCells
extension PeopleViewController {
    private func setUIForVisibleCells(items: [NSCollectionLayoutVisibleItem], point: CGPoint, enviroment: NSCollectionLayoutEnvironment) {
        
        items.forEach { visibleItem in
            let distanceFromCenter = abs((visibleItem.frame.midX - point.x) - enviroment.container.contentSize.width / 2.0)
           
            let minScale: CGFloat = 0.5
            let maxScale: CGFloat = 1
            let scale = max(maxScale - (distanceFromCenter / enviroment.container.contentSize.width / 2), minScale)
            visibleItem.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
}

//MARK: objc
extension PeopleViewController {
    //MARK: updateCurrentPeople
    @objc private func updateCurrentPeople() {
        if let people = UserDefaultsService.shared.getMpeople() {
            currentPeople = people
        }
    }
    
    //MARK: premiumIsUpdated
    @objc private func premiumIsUpdated() {
        reloadData(reloadSection: true, animating: false)
    }
    
    //MARK: checkPeopleNearbyIsEmpty
    private func checkPeopleNearbyIsEmpty()  {
        //if nearby people empty set
        guard let sortedPeopleNearby = peopleDelegate?.sortedPeopleNearby else { fatalError() }
        if sortedPeopleNearby.isEmpty {
            emptyView.hide(hidden: false)
        } else {
            emptyView.hide(hidden: true)
        }
    }
    
    //MARK: changeSearchTapped
    @objc private func changeSearchTapped() {
        
        let searchVC = EditSearchSettingsViewController(currentPeople: currentPeople,
                                                        peopleListnerDelegate: peopleDelegate,
                                                        likeDislikeDelegate: likeDislikeDelegate,
                                                        acceptChatsDelegate: acceptChatDelegate,
                                                        reportsDelegate: reportDelegate)
        searchVC.hidesBottomBarWhenPushed = true
        searchVC.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.pushViewController(searchVC, animated: true)
    }
}



//MARK: - PeopleCollectionViewDelegate
extension PeopleViewController: PeopleCollectionViewDelegate {
    
    
    //MARK:  updateData
    func updateData() {
        guard var snapshot = dataSource?.snapshot() else { return }
        guard let sortedPeopleNearby = peopleDelegate?.sortedPeopleNearby else { fatalError() }
        snapshot.appendItems(sortedPeopleNearby, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: true)
        
        checkPeopleNearbyIsEmpty()
    }
    
    
    //MARK:  reloadData
    func reloadData(reloadSection: Bool = false, animating: Bool = true) {
        
        var snapshot = NSDiffableDataSourceSnapshot<SectionsPeople,MPeople>()
        snapshot.appendSections([.main])
        guard let sortedPeopleNearby = peopleDelegate?.sortedPeopleNearby else { fatalError() }
        snapshot.appendItems(sortedPeopleNearby, toSection: .main)
        
        if reloadSection {
            snapshot.reloadSections([.main])
        }
        dataSource?.apply(snapshot, animatingDifferences: animating)
        
        checkPeopleNearbyIsEmpty()
    }
}

extension PeopleViewController {
    
    //MARK: checkLikeIsAvalible
    private func checkLikeIsAvalible(complition: @escaping() -> Void) {
        FirestoreService.shared.addLikeCount(currentPeople: currentPeople) {[weak self] result in
            switch result {
            
            case .success(let mPeople):
                self?.currentPeople = mPeople
                complition()
            case .failure(let error):
                //if error of count likes
                if error as? UserError == UserError.freeCountOfLike {
                    PopUpService.shared.bottomPopUp(header: "На сегодня лайки закончились",
                                                    text: "Хочешь еще? Безлимитные лайки и многое другое с подпиской Flava Premium",
                                                    image: nil,
                                                    okButtonText: "Перейти на Flava premium") { [ weak self] in
                        
                        guard let currentPeople = self?.currentPeople else { return }
                        let purchasVC = PurchasesViewController(currentPeople: currentPeople)
                        purchasVC.modalPresentationStyle = .fullScreen
                        self?.present(purchasVC, animated: true, completion: nil)
                    }
                } else {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
    
    //MARK: saveLikeToFireStore
    private func saveLikeToFireStore(people: MPeople) {
        
        guard let reportDelegate = reportDelegate else { fatalError("reportDelegate is nil") }
        guard let peopleDelegate = peopleDelegate else { fatalError("peopleDelegate is nil") }
        guard let requestChatDelegate = requestChatDelegate else { fatalError("requestChatDelegate is nil") }
        
        FirestoreService.shared.likePeople(currentPeople: currentPeople,
                                           likePeople: people,
                                           requestChats: requestChatDelegate.requestChats) {[weak self] result, isMatch  in
            switch result {
            
            case .success(let likeChat):
                
                
                //add to local likePeople collection only when, current like is not match
                if !isMatch {
                    self?.likeDislikeDelegate?.likePeople.append(likeChat)
                }
                
                self?.peopleDelegate?.deletePeople(peopleID: likeChat.friendId)
                
                
                
                if isMatch {
                    guard let currentPeople = self?.currentPeople else { return }
                    PopUpService.shared.showMatchPopUP(currentPeople: currentPeople, chat: likeChat) { messageDelegate, acceptChatDelegate in
                        let chatVC = ChatViewController(people: currentPeople,
                                                        chat: likeChat,
                                                        messageDelegate: messageDelegate,
                                                        acceptChatDelegate: acceptChatDelegate,
                                                        reportDelegate: reportDelegate,
                                                        peopleDelegate: peopleDelegate,
                                                        requestDelegate: requestChatDelegate)
                        chatVC.hidesBottomBarWhenPushed = true
                        
                        self?.navigationController?.pushViewController(chatVC, animated: true)
                    }
                }
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
}
//MARK: - likeDislikeDelegate
extension PeopleViewController: PeopleButtonTappedDelegate {
    
    func timeTapped() {
        PopUpService.shared.bottomPopUp(header: "Хочешь видеть время последней активности пользователя?",
                                        text: "Последняя активность, безлимитные лайки и многое другое с подпиской Flava Premium",
                                        image: nil,
                                        okButtonText: "Перейти на Flava premium") { [ weak self] in
            
            guard let currentPeople = self?.currentPeople else { return }
            let purchasVC = PurchasesViewController(currentPeople: currentPeople)
            purchasVC.modalPresentationStyle = .fullScreen
            self?.present(purchasVC, animated: true, completion: nil)
        }
    }
    
    func likePeople(people: MPeople) {
        print("Like")
        //check like  is avalible
        checkLikeIsAvalible { [weak self] in
            self?.saveLikeToFireStore(people: people)
        }
    }
    
    func dislikePeople(people: MPeople) {
       print("dislike")
        //save dislike to firestore
        FirestoreService.shared.dislikePeople(currentPeople: currentPeople,
                                              dislikeForPeopleID: people.senderId,
                                              requestChats: requestChatDelegate?.requestChats ?? [],
                                              viewControllerDelegate: self) {[weak self] result in
            switch result {

            case .success(let dislikeChat):
                //delete dislike people from array
                self?.peopleDelegate?.deletePeople(peopleID: people.senderId)
                //append to dislike array, for local changes
                self?.likeDislikeDelegate?.dislikePeople.append(dislikeChat)
               

            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func reportTapped(people: MPeople) {
        print("report \(people.displayName)")
        let reportVC = ReportViewController(currentUserID: currentPeople.senderId,
                                            reportUserID: people.senderId,
                                            isFriend: false,
                                            reportDelegate: reportDelegate,
                                            peopleDelegate: peopleDelegate,
                                            requestDelegate: requestChatDelegate)
        
        navigationController?.pushViewController(reportVC, animated: true)
    }
}

//MARK: setupConstraints
extension PeopleViewController {
    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.translatesAutoresizingMaskIntoConstraints = false
       
        view.addSubview(collectionView)
        view.addSubview(emptyView)
        
        
        
        NSLayoutConstraint.activate([
            emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            emptyView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
