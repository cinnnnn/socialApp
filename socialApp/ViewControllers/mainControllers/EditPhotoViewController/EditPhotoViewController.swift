//
//  EditPhotoViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 09.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SDWebImage

class EditPhotoViewController: UIViewController {
    
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
        setup()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProfileData()
    }
    
    //MARK: setup
    private func setup() {
        addImageButton.backgroundColor = .myLightGrayColor()
        profileImage.clipsToBounds = true
        view.backgroundColor = .myWhiteColor()
        
        addImageButton.addTarget(self, action: #selector(addImageButtonTap), for: .touchUpInside)
    }
    
    //MARK: updateProfileData
    private func updateProfileData() {
        currentPeople = UserDefaultsService.shared.getMpeople()
        if let images = currentPeople?.gallery  {
            updateDataSource(imagesStringURL: images)
        }
        guard let people = currentPeople else { return }
        guard let imageURL = URL(string: people.userImage) else { return }
        profileImage.sd_setImage(with: imageURL, completed: nil)
        updateDataSource(imagesStringURL: people.gallery)
    }
    
    @objc func addImageButtonTap() {
        let picker = UIImagePickerController()
        picker.delegate = self
        choosePhotoAlert {[weak self] sourceType in
            guard let sourceType = sourceType else { return }
            picker.sourceType = sourceType
            self?.present(picker, animated: true, completion: nil)
        }
    }
}

//MARK: collectionView
extension EditPhotoViewController {
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.frame,
                                          collectionViewLayout: setupLayout())
        collectionView.backgroundColor = .myWhiteColor()
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = false
        
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
    
    //MARK: updateDataSource
    private func updateDataSource(imagesStringURL: [String] = []) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionEditPhotos, String>()
        snapshot.appendSections([.photos])
        snapshot.appendItems(imagesStringURL, toSection: .photos)
        
        dataSource?.apply(snapshot)
    }
}

//MARK: - Alerts
extension EditPhotoViewController {
    private func editGalleryAlert(imageURLString: String, complition:@escaping()->Void) {
        guard let people = UserDefaultsService.shared.getMpeople() else { return }
        let photoAlert = UIAlertController(title: nil,
                                           message: nil,
                                           preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Сделать фото профиля",
                                         style: .default) { _ in
            FirestoreService.shared.updateAvatar(imageURLString: imageURLString,
                                                 currentAvatarURL: people.userImage,
                                                 id: people.senderId) { result in
                switch result {
                case .success(_):
                    complition()
                case .failure(_):
                    break
                }
            }
        }
        
        let libraryAction = UIAlertAction(title: "Удалить",
                                          style: .default) { _ in
                                     
            complition()
        }
        let cancelAction = UIAlertAction(title: "Отмена",
                                         style: .default) { _ in
            
        }
        
        photoAlert.setMyStyle()
        photoAlert.addAction(cameraAction)
        photoAlert.addAction(libraryAction)
        photoAlert.addAction(cancelAction)
        
        present(photoAlert, animated: true, completion: nil)
    }
    
    //MARK:  choosePhotoAlert
    private func choosePhotoAlert(complition: @escaping (_ sourceType:UIImagePickerController.SourceType?) -> Void) {
        
        let photoAlert = UIAlertController(title: nil,
                                           message: nil,
                                           preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Открыть камеру",
                                         style: .default) { _ in
                                            
                                            complition(UIImagePickerController.SourceType.camera)
        }
        let libraryAction = UIAlertAction(title: "Выбрать из галереи",
                                          style: .default) { _ in
                                            complition(UIImagePickerController.SourceType.photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "Отмена",
                                         style: .default) { _ in
                                            complition(nil)
        }
        
        photoAlert.setMyStyle()
        photoAlert.addAction(cameraAction)
        photoAlert.addAction(libraryAction)
        photoAlert.addAction(cancelAction)
        
        present(photoAlert, animated: true, completion: nil)
    }
    
    
}

extension EditPhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let stringImageURL = dataSource?.itemIdentifier(for: indexPath) else { return }
        
        editGalleryAlert(imageURLString: stringImageURL) { [weak self] in
            
            self?.updateProfileData()
        }
    }
}

//MARK:  UIImagePickerControllerDelegate
extension EditPhotoViewController:UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        guard var people = currentPeople else { return }
        //if user don't have profile image, set new to profile
        if people.userImage == "" {
            FirestoreService.shared.saveAvatar(image: image, id: people.senderId) {[weak self] result in
                switch result {
                case .success(let userImageString):
                    people.userImage = userImageString
                    self?.currentPeople = people
                    UserDefaultsService.shared.saveMpeople(people: people)
                    self?.profileImage.image = image
                case .failure(let error):
                    fatalError(error.localizedDescription)
                }
            }
            //if user have profile image, save to gallery
        } else {
            FirestoreService.shared.saveImageToGallery(image: image, id: people.senderId) {[weak self] result in
                switch result {
                
                case .success(let imageURLString):
                    people.gallery.append(imageURLString)
                    self?.currentPeople = people
                    UserDefaultsService.shared.saveMpeople(people: people)
                    self?.updateDataSource(imagesStringURL: people.gallery)
                case .failure(let error):
                    fatalError(error.localizedDescription)
                }
            }
        }
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
            addImageButton.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 10),
            addImageButton.widthAnchor.constraint(equalToConstant: 70),
            addImageButton.heightAnchor.constraint(equalTo: addImageButton.widthAnchor),
            
            collectionView.leadingAnchor.constraint(equalTo: addImageButton.trailingAnchor, constant: 10),
            collectionView.topAnchor.constraint(equalTo: addImageButton.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
}
