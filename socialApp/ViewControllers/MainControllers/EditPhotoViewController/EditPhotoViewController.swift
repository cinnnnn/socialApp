//
//  EditPhotoViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 09.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import FirebaseAuth
import SDWebImage

class EditPhotoViewController: UIViewController {
    
    let profileImage = UIImageView(image: nil, contentMode: .scaleAspectFill)
    let scrollView = UIScrollView()
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<SectionEditPhotos, MGallery>?
    
    let addImageButton = UIButton(image: UIImage(systemName: "plus",
                                                 withConfiguration: UIImage.SymbolConfiguration(pointSize: 24,
                                                                                                weight: .bold,
                                                                                                scale: .default)) ?? #imageLiteral(resourceName: "plus"))
    let tipsHeader = UILabel(labelText: "Советы",
                             textFont: .avenirRegular(size: 16))
    let tips = UILabel(labelText: MLabels.editPhotoTips.rawValue,
                       textFont: .avenirRegular(size: 16),
                       textColor: .myGrayColor(),
                       linesCount: 0)
    let privateHeader = UILabel(labelText: "Приватные фото",
                                textFont: .avenirRegular(size: 16))
    let privateLabel = UILabel(labelText: MLabels.privatePhotoTips.rawValue,
                               textFont: .avenirRegular(size: 16),
                               textColor: .myGrayColor(),
                               linesCount: 0)
    let legalHeader = UILabel(labelText: "Юридическая информация",
                              textFont: .avenirRegular(size: 16))
    let legal = UILabel(labelText: MLabels.editPhotoLegal.rawValue,
                        textFont: .avenirRegular(size: 16),
                        textColor: .myGrayColor(),
                        linesCount: 0)
    
    var images: [MGallery] = []
    var currentPeople: MPeople? {
        didSet {
            images = []
            guard let currentPeople = currentPeople else { return }
            for image in currentPeople.gallery {
                images.append(MGallery(photo: image.key,
                                       property: MGalleryPhotoProperty(isPrivate: image.value.isPrivate,
                                                                       index: image.value.index)))
            }
            images.sort { $0.property.index > $1.property.index }
        }
    }
    var userID: String
    var isFirstSetup = false
    
    init (userID: String, isFirstSetup: Bool) {
        self.userID = userID
        self.isFirstSetup = isFirstSetup
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit photo")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupDataSource()
        setupConstraints()
        setup()
        updateProfileData(isRenew: false) { }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.updateContentView(bottomOffset: 45)
    }
    
    //MARK: setup
    private func setup() {
        addImageButton.backgroundColor = .mySecondButtonColor()
        addImageButton.imageView?.tintColor = .mySecondButtonLabelColor()
        addImageButton.clipsToBounds = true
        profileImage.backgroundColor = .myGrayColor()
        profileImage.clipsToBounds = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.layoutSubviews()
        
        view.backgroundColor = .myWhiteColor()
        navigationItem.title = "Галерея"
        
        addImageButton.addTarget(self, action: #selector(addImageButtonTap), for: .touchUpInside)
        
        if isFirstSetup {
            navigationItem.setHidesBackButton(true, animated: false)
            navigationItem.title = "Фото"
            navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done,
                                                             target: self,
                                                             action: #selector(saveButtonTapped)),
                                             animated: false)
        } else {
            NotificationCenter.addObsorverToPremiumUpdate(observer: self, selector: #selector(premiumIsUpdate))
        }
    }
    
    //MARK: updateProfileData
     private func updateProfileData(isRenew: Bool, complition: (()->())?) {
        
        if isRenew {
            currentPeople = UserDefaultsService.shared.getMpeople()
        } else {
            //if first setup Photo -> get from Firebase else get from UserDefaults
            if isFirstSetup {
                FirestoreService.shared.getUserData(userID: userID, complition: {[weak self] result in
                    switch result {
                    
                    case .success(let mPeople):
                        self?.currentPeople = mPeople
                        UserDefaultsService.shared.saveMpeople(people: mPeople)
                    case .failure(let error):
                        fatalError(error.localizedDescription)
                    }
                })
            } else {
                currentPeople = UserDefaultsService.shared.getMpeople()
            }
        }
        
        guard let people = currentPeople else { return }
        guard let imageURL = URL(string: people.userImage) else { return }
        profileImage.sd_setImage(with: imageURL, completed: nil)
        
        updateDataSource(galleryImages: images)
    
    }
}

//MARK: objc
extension EditPhotoViewController {
    @objc private func premiumIsUpdate() {
        updateProfileData(isRenew: true, complition: nil)
    }
    
    @objc private func addImageButtonTap() {
        let picker = UIImagePickerController()
        picker.delegate = self
        choosePhotoAlert {[weak self] sourceType in
            guard let sourceType = sourceType else { return }
            picker.sourceType = sourceType
            self?.present(picker, animated: true, completion: nil)
            
        }
    }
    
    @objc private func saveButtonTapped() {
        //if image is setup
        if profileImage.image != nil {
            navigationItem.rightBarButtonItem?.isEnabled = false
            FirestoreService.shared.getUserData(userID: userID) {[weak self] result in
                switch result {
                
                case .success(let mPeople):
                    let mainTabBarVC = MainTabBarController(currentUser: mPeople, isNewLogin: true)
                    mainTabBarVC.modalPresentationStyle = .fullScreen
                    self?.navigationController?.dismiss(animated: false, completion: {[weak self] in
                        self?.navigationController?.removeFromParent()
                        let vc = UIApplication.getCurrentViewController()
                        vc?.present(mainTabBarVC, animated: false, completion: nil)
                    })
                case .failure(_):
                    self?.navigationItem.rightBarButtonItem?.isEnabled = true
                    PopUpService.shared.showInfo(text: "Не удалось загрузить профиль")
                }
            }
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
            PopUpService.shared.bottomPopUp(header: "А как же фото?",
                                            text: "Необходимо опубликовать минимум одно фото",
                                            image: nil,
                                            okButtonText: "Добавить фото") { [weak self] in
                self?.addImageButtonTap()
            }
        }
    }
}


//MARK: - CollectionView
extension EditPhotoViewController {
    
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.frame,
                                          collectionViewLayout: setupLayout())
        collectionView.backgroundColor = .myWhiteColor()
        collectionView.delegate = self
        collectionView.contentSize.height = 10
        collectionView.register(EditPhotoCell.self, forCellWithReuseIdentifier: EditPhotoCell.reuseID)
    }
    
    private func setupPhotosSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.37),
//                                               heightDimension: .fractionalWidth(0.37))
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(collectionView.frame.height),
                                               heightDimension: .absolute(collectionView.frame.height))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10
    
        section.contentInsets = NSDirectionalEdgeInsets(top: 0,
                                                        leading: 10,
                                                        bottom: 0,
                                                        trailing: 10)
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
                cell.configure(galleryImage: element.photo, isPrivate: element.property.isPrivate) {
                    cell.layoutIfNeeded()
                }
                return cell
            })
    }
    
    //MARK: updateDataSource
    private func updateDataSource(galleryImages: [MGallery]) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionEditPhotos, MGallery>()
        snapshot.appendSections([.photos])
        snapshot.appendItems(galleryImages, toSection: .photos)
        
        dataSource?.apply(snapshot)
    }
}

extension EditPhotoViewController {
    private func sortGalleryImages(complition: @escaping ()->()) {
        guard let currentPeople = currentPeople else { return }
        images.sort{$0.property.index > $1.property.index }
        for index in 0..<images.count {
            images[index].property.index = index
            FirestoreService.shared.saveImageToGallery(image: nil,
                                                       uploadedImageLink: images[index].photo,
                                                       id: currentPeople.senderId,
                                                       isPrivate: images[index].property.isPrivate,
                                                       index: index) { _ in }
        }
        complition()
    }
}
//MARK: - Alerts
extension EditPhotoViewController {

    
    private func editGalleryAlert(galleryImage: MGallery, index: Int, complition:@escaping()->Void) {
        guard let people = currentPeople else { return }
        let privateActionText = galleryImage.property.isPrivate ? "Сделать общедоступной " : "Сделать приватной"
        
        let photoAlert = UIAlertController(title: nil,
                                           message: nil,
                                           preferredStyle: .actionSheet)
        
        if galleryImage.property.isPrivate {
            
        }
        //make profile image
        let makeProfileAction = UIAlertAction(title: "Сделать основной",
                                         style: .default) { _ in
            FirestoreService.shared.updateAvatar(galleryImage: galleryImage,
                                                 currentAvatarURL: people.userImage,
                                                 id: people.senderId) {[weak self] result in
                switch result {
                case .success(_):
                    self?.updateProfileData(isRenew: true) {
                        complition()
                    }
                case .failure(_):
                    break
                }
            }
                                         }
        
        //make private image
        let privateAction = UIAlertAction(title: privateActionText,
                                         style: .default) { _ in
            if people.isGoldMember || people.isTestUser {
                FirestoreService.shared.makePhotoPrivate(currentUser: people,
                                                         galleryPhoto: galleryImage) {[weak self] result in
                    switch result {
                    
                    case .success(_):
                        self?.updateProfileData(isRenew: true, complition: {
                            complition()
                        })
                    case .failure(let error):
                        PopUpService.shared.showInfo(text: "Ошибка: \(error.localizedDescription)")
                    }
                }
            } else {
                PopUpService.shared.bottomPopUp(header: "Сделай фото приватной и ее увидят только твои друзья",
                                                text: "Данная функция доступна с подпиской Flava premium",
                                                image: nil,
                                                okButtonText: "Перейти на Flava premium") { [weak self] in
                    let purchasVC = PurchasesViewController(currentPeople: people)
                    purchasVC.modalPresentationStyle = .fullScreen
                    self?.present(purchasVC, animated: true, completion: nil)
                }
            }
        }
        //delete image
        let deleteAction = UIAlertAction(title: "Удалить",
                                          style: .default) { _ in
            FirestoreService.shared.deleteFromGallery(galleryImage: galleryImage,
                                                      id: people.senderId) {[weak self] result in
                switch result {
                
                case .success(_):
                    self?.images.remove(at: index)
                    //sort gallery images, for change images index
                    self?.sortGalleryImages(complition: {
                        self?.updateProfileData(isRenew: true)  {
                            complition()
                        }
                    })
                    
                case .failure(let errror):
                    fatalError(errror.localizedDescription)
                }
            }
                                          }
        
        let cancelAction = UIAlertAction(title: "Отмена",
                                         style: .default) { _ in }
        
        photoAlert.setMyStyle()
        
        //add private action only edit screen
        if !isFirstSetup {
            photoAlert.addAction(privateAction)
        }
        photoAlert.addAction(makeProfileAction)
        photoAlert.addAction(deleteAction)
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

//MARK: collectionViewDelegate
extension EditPhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let galleryImage = dataSource?.itemIdentifier(for: indexPath) else { return }
        
        editGalleryAlert(galleryImage: galleryImage, index: indexPath.row) { }
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
                case .success(_):
                    
                    self?.currentPeople = UserDefaultsService.shared.getMpeople()
                    self?.profileImage.image = image
                    
                case .failure(let error):
                    fatalError(error.localizedDescription)
                }
            }
            //if user have profile image, save to gallery
        } else {
            let indexOfImage = images.count
            FirestoreService.shared.saveImageToGallery(image: image, id: people.senderId, isPrivate: false, index: indexOfImage) {[weak self] result in
                switch result {
                
                case .success(let imageURLString):
                    people.gallery[imageURLString] = MGalleryPhotoProperty(isPrivate: false,
                                                                           index: indexOfImage)
                    self?.currentPeople = people
                    UserDefaultsService.shared.saveMpeople(people: people)
                    guard let images = self?.images else { return }
                    self?.updateDataSource(galleryImages: images)
                case .failure(let error):
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
}

//MARK: setupConstraints
extension EditPhotoViewController {
    private func setupConstraints() {
        view.addSubview(scrollView)
        scrollView.addSubview(profileImage)
        scrollView.addSubview(addImageButton)
        scrollView.addSubview(collectionView)
        scrollView.addSubview(tipsHeader)
        scrollView.addSubview(tips)
        scrollView.addSubview(legalHeader)
        scrollView.addSubview(legal)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addImageButton.translatesAutoresizingMaskIntoConstraints = false
        tipsHeader.translatesAutoresizingMaskIntoConstraints = false
        tips.translatesAutoresizingMaskIntoConstraints = false
        legalHeader.translatesAutoresizingMaskIntoConstraints = false
        legal.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            profileImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            profileImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            profileImage.topAnchor.constraint(equalTo: scrollView.topAnchor),
            profileImage.heightAnchor.constraint(equalTo: profileImage.widthAnchor),
            
            addImageButton.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            addImageButton.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 10),
            addImageButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.25),
            addImageButton.heightAnchor.constraint(equalTo: addImageButton.widthAnchor),
            
            collectionView.leadingAnchor.constraint(equalTo: addImageButton.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: addImageButton.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: addImageButton.bottomAnchor),
            
            tipsHeader.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            tipsHeader.trailingAnchor.constraint(equalTo: profileImage.trailingAnchor),
            tipsHeader.topAnchor.constraint(equalTo: addImageButton.bottomAnchor, constant: 20),
            
            tips.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            tips.trailingAnchor.constraint(equalTo: profileImage.trailingAnchor),
            tips.topAnchor.constraint(equalTo: tipsHeader.bottomAnchor, constant: 10),

        ])
        
        if isFirstSetup {
            NSLayoutConstraint.activate([
                legalHeader.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
                legalHeader.trailingAnchor.constraint(equalTo: profileImage.trailingAnchor),
                legalHeader.topAnchor.constraint(equalTo: tips.bottomAnchor, constant: 25),
                
                legal.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
                legal.trailingAnchor.constraint(equalTo: profileImage.trailingAnchor),
                legal.topAnchor.constraint(equalTo: legalHeader.bottomAnchor, constant: 10),
            ])
        } else {
            privateHeader.translatesAutoresizingMaskIntoConstraints = false
            privateLabel.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview(privateHeader)
            scrollView.addSubview(privateLabel)
            
            NSLayoutConstraint.activate([
                privateHeader.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
                privateHeader.trailingAnchor.constraint(equalTo: profileImage.trailingAnchor),
                privateHeader.topAnchor.constraint(equalTo: tips.bottomAnchor, constant: 25),
                
                privateLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
                privateLabel.trailingAnchor.constraint(equalTo: profileImage.trailingAnchor),
                privateLabel.topAnchor.constraint(equalTo: privateHeader.bottomAnchor, constant: 10),
                
                legalHeader.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
                legalHeader.trailingAnchor.constraint(equalTo: profileImage.trailingAnchor),
                legalHeader.topAnchor.constraint(equalTo: privateLabel.bottomAnchor, constant: 25),
                
                legal.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
                legal.trailingAnchor.constraint(equalTo: profileImage.trailingAnchor),
                legal.topAnchor.constraint(equalTo: legalHeader.bottomAnchor, constant: 10),
            ])
        }
    }
}
