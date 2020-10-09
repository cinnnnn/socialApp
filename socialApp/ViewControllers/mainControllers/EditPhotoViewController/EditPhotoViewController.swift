//
//  EditPhotoViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 09.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SDWebImage

class EditPhotoViewController: UIViewController, UICollectionViewDelegate {
    
    let profileImage = UIImageView(image: nil, contentMode: .scaleAspectFill)
    var collectionView: UICollectionView!
    let addImageButton = UIButton(image: #imageLiteral(resourceName: "plus"))
    var dataSource: UICollectionViewDiffableDataSource<SectionEditPhotos, String>?
    var images: [String] = []
    var currentPeople: MPeople?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupDataSource()
        setupConstraints()
        
        view.backgroundColor = .myWhiteColor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        currentPeople = UserDefaultsService.shared.getMpeople()
        setup()
    }
    
    private func setup() {
        
        addImageButton.backgroundColor = .myLightGrayColor()
        profileImage.clipsToBounds = true
        
        if let images = currentPeople?.gallery  {
            updateDataSource(imagesStringURL: images)
        }
        guard let people = currentPeople else { return }
        guard let imageURL = URL(string: people.userImage) else { return }
        profileImage.sd_setImage(with: imageURL, completed: nil)
        updateDataSource(imagesStringURL: [people.userImage])
    
    }
}

//MARK: collectionView
extension EditPhotoViewController {
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.frame,
                                          collectionViewLayout: setupLayout())
        collectionView.backgroundColor = .myWhiteColor()
        collectionView.delegate = self
        
        collectionView.register(EditPhotoCell.self, forCellWithReuseIdentifier: EditPhotoCell.reuseID)
    }
    
    private func setupPhotosSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(70),
                                               heightDimension: .absolute(70))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 10
        return section
    }
    
    //MARK: setupLayout
    private func setupLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {[weak self] section, environment -> NSCollectionLayoutSection? in
            guard let section = SectionEditPhotos(rawValue: section) else { fatalError("Unknow section")}
            
            switch section {
            case .photos:
            return self?.setupPhotosSection()
            }
        }
        return layout
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, element) -> UICollectionViewCell? in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EditPhotoCell.reuseID, for: indexPath) as? EditPhotoCell else { fatalError("Cant cast EditPhotoCell") }
                    cell.configure(imageStringURL: element) {
                        cell.layoutIfNeeded()
                }
                return cell
            })
    }
    
    private func updateDataSource(imagesStringURL: [String] = []) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionEditPhotos, String>()
        snapshot.appendSections([.photos])
        snapshot.appendItems(imagesStringURL, toSection: .photos)
        
        dataSource?.apply(snapshot)
    }
}

extension EditPhotoViewController {
    private func setupConstraints() {
        view.addSubview(profileImage)
        view.addSubview(addImageButton)
        view.addSubview(collectionView)
 
        
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addImageButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            profileImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            profileImage.heightAnchor.constraint(equalTo: profileImage.widthAnchor),
            
            addImageButton.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            addImageButton.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 25),
            addImageButton.widthAnchor.constraint(equalToConstant: 70),
            addImageButton.heightAnchor.constraint(equalTo: addImageButton.widthAnchor),
            
            collectionView.leadingAnchor.constraint(equalTo: addImageButton.trailingAnchor, constant: 10),
            collectionView.topAnchor.constraint(equalTo: addImageButton.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: profileImage.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
}
