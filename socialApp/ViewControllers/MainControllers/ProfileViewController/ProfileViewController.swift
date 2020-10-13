//
//  ProfileViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 07.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController:UIViewController {
    
    weak private var setupProfileVC:SetProfileViewController?
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<SectionsProfile, MSettings>?
    private var currentPeople: MPeople?
    private var currentUser: User
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupCollectionView()
        setupDataSource()
        updateDataSource()
        getPeopleData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getPeopleData()
    }
    
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        navigationController?.navigationBar.isHidden = true
        navigationItem.backButtonTitle = "Профиль"
        navigationController?.navigationBar.tintColor = .label
        
    }
}

//MARK: getLocation
extension ProfileViewController {
    private func getLocation() {
        guard let people = currentPeople else { return }
        LocationService.shared.getCoordinate(userID: people.senderId) {[weak self] isAllowPermission in
            //if geo is denied, show alert and go to settings
            if isAllowPermission == false {
                self?.openSettingsAlert()
            }
        }
    }
}

//MARK: getPeopleData
extension ProfileViewController {
    private func getPeopleData() {
        guard let email = currentUser.email else { return }
        FirestoreService.shared.getUserData(userID: email) {[weak self] result in
            switch result {
            case .success(let mPeople):
                self?.currentPeople = mPeople
                UserDefaultsService.shared.saveMpeople(people: mPeople)
                self?.updateProfileSection()
                self?.getLocation()
            case .failure(_):
                //if get incorrect info from mPeople profile, logOut and go to authVC
                AuthService.shared.signOut { result in
                    switch result {
                    case .success(_):
                        self?.dismiss(animated: true) {
                            let navVC = UINavigationController(rootViewController: AuthViewController())
                            navVC.navigationBar.isHidden = true
                            navVC.navigationItem.backButtonTitle = "Войти с Apple ID"
                            self?.present(navVC, animated: false, completion: nil)
                        }
                        
                    case .failure(let error):
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
    }
}

//MARK: setupCollectionView
extension ProfileViewController {
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: setupLayout())
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = .myWhiteColor()
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: ProfileCell.reuseID)
        collectionView.register(SettingsCell.self, forCellWithReuseIdentifier: SettingsCell.reuseID)
    }
    
    private func setupProfileSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(400))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    
    private func setupSettingsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(70))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    //MARK: setupLayout
    private func setupLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {[weak self] section, environment -> NSCollectionLayoutSection? in
            guard let section = SectionsProfile(rawValue: section) else { fatalError("Unknow section")}
            
            switch section {
            case .profile:
                return self?.setupProfileSection()
            case .settings:
                return self?.setupSettingsSection()
            }
        }
        return layout
    }
    
    //MARK: setupDataSource
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: {[weak self] collectionView, indexpath, item -> UICollectionViewCell? in
                
                guard let section = SectionsProfile(rawValue: indexpath.section) else { fatalError("Unknown section")}
                
                switch section {
                
                case .profile:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCell.reuseID, for: indexpath) as? ProfileCell else { fatalError("Can't dequeue cell type ProfileCell")}
                    
                    cell.configure(people: self?.currentPeople)
                    cell.layoutIfNeeded()
                    return cell
                    
                case .settings:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsCell.reuseID, for: indexpath) as? SettingsCell else { fatalError("Can't dequeue cell type SettingsCell")}
                    
                    cell.configure(settings: item)
                    return cell
                }
            }
        )
    }
    
    //MARK: updateProfileSection
    private func updateProfileSection() {
        guard var snapshot = dataSource?.snapshot() else { return }
        snapshot.reloadSections([ .profile])
        dataSource?.apply(snapshot)
    }
    
    //MARK: updateProfileSection
    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionsProfile, MSettings>()
        snapshot.appendSections([.profile,.settings])
        snapshot.appendItems([MSettings.profileInfo], toSection: .profile)
        snapshot.appendItems([MSettings.setupProfile, MSettings.setupSearch, MSettings.about],
                             toSection: .settings)
        dataSource?.apply(snapshot)
    }
}

//MARK: collectionViewDelegate
extension ProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let section = SectionsProfile(rawValue: indexPath.section) else { return }
        
        if section == .settings {
            guard let cell = MSettings(rawValue: indexPath.row + 1) else { fatalError("unknown cell")}
            
            switch cell {
            
            case .setupProfile:
                let vc = SetProfileViewController()
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
                
                collectionView.deselectItem(at: indexPath, animated: true)
            case .setupSearch:
                let newVC = DateOfBirthViewController(currentUser: currentUser)
                newVC.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(newVC, animated: true)
                
                collectionView.deselectItem(at: indexPath, animated: true)
            case .about:
                break
            default:
                break
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
    }
}

extension ProfileViewController {
    //MARK: openSettingsAlert
    private func openSettingsAlert(){
        let alert = UIAlertController(title: "Нет доступа к геопозиции",
                                      text: "Необходимо разрешить доступ к геопозиции в настройках",
                                      buttonText: "Перейти в настройки",
                                      style: .alert) {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        present(alert, animated: true, completion: nil)
    }
}
