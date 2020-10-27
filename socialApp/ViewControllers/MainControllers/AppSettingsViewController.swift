//
//  AppSettingsViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 27.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class AppSettingsViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<SectionAppSettings, MAppSettings>?
    private var currentPeople: MPeople
    
    init(currentPeople: MPeople) {
        self.currentPeople = currentPeople
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupCollectionView()
        setupConstraints()
        setupDataSource()
        updateDataSource()
    }
    
    private func setup() {
        view.backgroundColor = .myWhiteColor()
        
        navigationItem.backButtonTitle = ""
        navigationItem.largeTitleDisplayMode = .never
    }
}

//MARK: setupCollectionView
extension AppSettingsViewController {
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: setupLayout())
        collectionView.backgroundColor = .myWhiteColor()
        collectionView.delegate = self
        
        collectionView.register(SettingsCell.self, forCellWithReuseIdentifier: SettingsCell.reuseID)
    }
    
    private func setupAppSettingsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .absolute(50))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                        leading: 25,
                                                        bottom: 0,
                                                        trailing: 25)
        
        return section
    }
    
    //MARK: setupLayout
    private func setupLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {[weak self] section, environment -> NSCollectionLayoutSection? in
            guard let section = SectionAppSettings(rawValue: section) else { fatalError("Unknow section")}
            
            switch section {
            case .appSettings:
                return self?.setupAppSettingsSection()
            }
        }
        return layout
    }
    
    //MARK: setupDataSource
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { collectionView, indexpath, item -> UICollectionViewCell? in
                
                guard let section = SectionAppSettings(rawValue: indexpath.section) else { fatalError("Unknown section")}
                
                switch section {
                
                case .appSettings:
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingsCell.reuseID, for: indexpath) as? SettingsCell else { fatalError("Can't dequeue cell type SettingsCell")}
                    
                    cell.configure(settings: item)
                    cell.layoutIfNeeded()
                    return cell
                }
            }
        )
    }
    
    //MARK: updateDataSource
    private func updateDataSource() {
        var snapshot = NSDiffableDataSourceSnapshot<SectionAppSettings, MAppSettings>()
        snapshot.appendSections([.appSettings])
        let items = MAppSettings.allCases
        snapshot.appendItems( items, toSection: .appSettings)
        
        dataSource?.apply(snapshot)
    }
}

//MARK: collectionViewDelegate
extension AppSettingsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let section = SectionAppSettings(rawValue: indexPath.section) else { return }
        
        if section == .appSettings {
            guard let cell = MAppSettings(rawValue: indexPath.row ) else { fatalError("unknown cell")}
            
            switch cell {
            
            case .about:
                break
            case .logOut:
               signOutAlert(pressedIndexPath: indexPath)
            case .terminateAccaunt:
                break
            }
        }
    }
}

extension AppSettingsViewController {
    //MARK:  signOutAlert
    private func signOutAlert(pressedIndexPath: IndexPath) {
        let alert = UIAlertController(title: nil,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        let okAction = UIAlertAction(title: "Выйду, но вернусь",
                                     style: .destructive) {[weak self] _ in
            
            self?.view.addCustomTransition(type: .fade)
            AuthService.shared.signOut { result in
                switch result {
                case .success(_):
                    return
                case .failure(let error):
                    fatalError(error.localizedDescription)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Продолжу общение",
                                         style: .default) { [weak self] _ in
            self?.collectionView.deselectItem(at: pressedIndexPath, animated: true)
        }
        
        alert.setMyStyle()
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

//MARK: setupConstraints
extension AppSettingsViewController {
    private func setupConstraints() {
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}


