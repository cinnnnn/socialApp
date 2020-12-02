//
//  SetProfileViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 04.07.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI
import FirebaseAuth
import SDWebImage
import MapKit

class EditProfileViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let gelleryScrollView = GalleryView(profileImage: "", gallery: [:], showPrivate: true, showProtectButton: true)
    let nameLabel = UILabel(labelText: "Вымышленное имя:",
                            textFont: .avenirRegular(size: 16),
                            textColor: .myGrayColor())
    let aboutLabel = UILabel(labelText: "Обо мне:",
                             textFont: .avenirRegular(size: 16),
                             textColor: .myGrayColor())
    let genderButton = OneLineButtonWithHeader(header: "Гендер", info: "")
    let sexualityButton = OneLineButtonWithHeader(header: "Сексуальная ориентация", info: "")
    let nameTextField = OneLineTextField(isSecureText: false,
                                         tag: 1,
                                         placeHoledText: "")
    let interestsTags = TagsCollectionView(unselectTags: [],
                                           selectTags: [],
                                           headerText: "Интересы",
                                           headerFont: .avenirRegular(size: 16),
                                           headerColor: .myGrayColor())
    let desireTags = TagsCollectionView(unselectTags: [],
                                           selectTags: [],
                                           headerText: "Твои желания",
                                           headerFont: .avenirRegular(size: 16),
                                           headerColor: .myGrayColor())
    let advertTextView = UITextView(text: "",
                                    isEditable: true)
    
    let editPhotosButton = RoundButton(newBackgroundColor: .myFirstButtonColor(),
                                       title: "Редактировать фото",
                                       titleColor: .myFirstButtonLabelColor())
    let incognitoLabel = UILabel(labelText: "Инкогнито",
                                textFont: .avenirRegular(size: 16),
                                textColor: .mySecondSatColor())
    let incognitoAboutLabel = UILabel(labelText: "Тебя не увидят другие пользователи, пока ты не поставишь им лайк",
                                textFont: .avenirRegular(size: 16),
                                textColor: .mySecondColor(),
                                linesCount: 0)
    let incognitoSwitch = UISwitch()
    
    private var selectedVisibleYValue: CGFloat?
    private var keybordMinYValue:CGFloat?
    
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
        setupConstraints()
        setupButtonAction()
        setupVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationController()
        registerNotification()
        setPeopleData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.updateContentView()
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        savePeopleData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.updateContentView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        gelleryScrollView.prepareReuseScrollView()
    }

    private func setupVC() {
        view.backgroundColor = .myWhiteColor()
        
        scrollView.delegate = self
        scrollView.addSingleTapRecognizer(target: self, selector: #selector(endEditing))
       
        advertTextView.delegate = self
        nameTextField.delegate = self
        interestsTags.tagsDelegate = self
        desireTags.tagsDelegate = self
        
        gelleryScrollView.clipsToBounds = true
        advertTextView.addDoneButton()
        editPhotosButton.layoutIfNeeded()
        incognitoSwitch.tintColor = .mySecondSatColor()
        incognitoSwitch.onTintColor = .mySecondColor()
        incognitoSwitch.thumbTintColor = .myWhiteColor()
    }
    
    //MARK:  setupNavigationController
    private func setupNavigationController(){
        navigationItem.title = "Профиль"
        navigationItem.backButtonTitle = ""
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK:  setupButtonAction
    private func setupButtonAction() {
        editPhotosButton.addTarget(self, action: #selector(editPhotosButtonTap), for: .touchUpInside)
        genderButton.addTarget(self, action: #selector(genderSelectTapped), for: .touchUpInside)
        sexualityButton.addTarget(self, action: #selector(sexualitySelectTapped), for: .touchUpInside)
        incognitoSwitch.addTarget(self, action: #selector(incognitoSwitchChanged), for: .touchUpInside)
    }
}


extension EditProfileViewController {
    //MARK:  setPeopleData
    private func setPeopleData() {
        
        guard let people = UserDefaultsService.shared.getMpeople() else { return }
        currentPeople = people
        interestsTags.configure(unselectTags: [],
                                selectedTags: people.interests)
        desireTags.configure(unselectTags: [],
                             selectedTags: people.desires)
        
        gelleryScrollView.setupImages(profileImage: people.userImage,
                                      gallery: people.gallery,
                                      showPrivate: true,
                                      showProtectButton: true,
                                      complition: {
                                        self.gelleryScrollView.layoutSubviews()
        })
        
        nameTextField.text = people.displayName
        advertTextView.text = people.advert
        genderButton.infoLabel.text = people.gender
        sexualityButton.infoLabel.text = people.sexuality
        incognitoSwitch.isOn = people.isIncognito
        
    }
    
    //MARK:  savePeopleData
    private func savePeopleData() {
        let name = nameTextField.text ?? ""
        let advert = advertTextView.text ?? ""
        let id = currentPeople.senderId
        let isIncognito = incognitoSwitch.isOn
        let interestsSelectedTags = interestsTags.getSelectedTags()
        let desiresSelectedTags = desireTags.getSelectedTags()
        
        guard let gender = genderButton.infoLabel.text else { fatalError("Can't get gender from button")}
        guard let sexuality = sexualityButton.infoLabel.text else { fatalError("Can't get sexuality from button")}
        FirestoreService.shared.saveProfileAfterEdit(id: id,
                                                     name: name,
                                                     advert: advert,
                                                     gender: gender,
                                                     sexuality: sexuality,
                                                     interests: interestsSelectedTags,
                                                     desires: desiresSelectedTags,
                                                     isIncognito: isIncognito) { result in
            switch result {
            
            case .success():
                return
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
}

//MARK: NotificationCenter
extension EditProfileViewController {
    private func registerNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateView(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateView(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.addObsorverToPremiumUpdate(observer: self,
                                                      selector: #selector(premiumIsUpdated))
    }
    
}

//MARK: objc extension
extension EditProfileViewController {
    
    @objc func editPhotosButtonTap() {
        let id = currentPeople.senderId
        let vc = EditPhotoViewController(userID: id,isFirstSetup: false)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: endEditing
    @objc func endEditing() {
        view.endEditing(true)
    }
    
    //MARK: genderSelectTapped
    @objc private func genderSelectTapped() {
        let vc = SelectionViewController(elements: MGender.modelStringAllCases,
                                         description: MGender.description,
                                         selectedValue: genderButton.infoLabel.text ?? "",
                                         complition: {[weak self] selected in
                                            self?.genderButton.infoLabel.text = selected
                                         })
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        
        present(vc, animated: true, completion: nil)
    }

    //MARK: sexualitySelectTapped
    @objc private func sexualitySelectTapped() {
        let vc = SelectionViewController(elements: MSexuality.modelStringAllCases,
                                         description: MSexuality.description,
                                         selectedValue: sexualityButton.infoLabel.text ?? "",
                                         complition: { [weak self] selected in
                                            self?.sexualityButton.infoLabel.text = selected
                                         })
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        
        present(vc, animated: true, completion: nil)
    }
    
    //MARK: updateView
    @objc func updateView(notification: Notification?) {
        
        let info = notification?.userInfo
        guard let keyboardSize = info?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let size = keyboardSize.cgRectValue
        let toolBarHight:CGFloat = 100
        keybordMinYValue = size.minY
        
        if notification?.name == UIResponder.keyboardWillShowNotification  {
         
        guard let value = selectedVisibleYValue else { return }
            let scrollValue  = value - size.minY + toolBarHight
            let scrollPoint = CGPoint(x: 0, y: scrollValue)
            scrollView.setContentOffset(scrollPoint, animated: true)
        }
        
        if notification?.name == UIResponder.keyboardWillHideNotification {
           // view.frame.origin.y = 0
        }
    }
    
    //MARK: forceUpdateContentOffset
    private func forceUpdateContentOffset(inset: CGFloat) {
        guard let keyboardYValue = keybordMinYValue else { return }
        let toolBarHight:CGFloat = 100
        guard let value = selectedVisibleYValue else { return }
        let scrollValue  = value - keyboardYValue + toolBarHight + inset
        let scrollPoint = CGPoint(x: 0, y: scrollValue)
        scrollView.setContentOffset(scrollPoint, animated: true)
    }
    
    
    //MARK: incognitoSwitchChanged
    @objc private func incognitoSwitchChanged(){
        if !PurchasesService.shared.checkActiveSubscribtionWithApphud() {
            PopUpService.shared.bottomPopUp(header: "Режим инкогнито",
                                            text: "Данный режим доступен с подпиской Flava premium",
                                            image: nil,
                                            okButtonText: "Перейти на Flava premium") { [weak self] in
                guard let currentPeople = self?.currentPeople else { return }
                let purchasVC = PurchasesViewController(currentPeople: currentPeople)
                purchasVC.modalPresentationStyle = .fullScreen
                self?.present(purchasVC, animated: true, completion: nil)
            }
            incognitoSwitch.isOn.toggle()
        }
    }
    
    @objc private func premiumIsUpdated() {
        if let updatedUser = UserDefaultsService.shared.getMpeople() {
            self.currentPeople = updatedUser
            setPeopleData()
        }
    }
}


//MARK:  UITextFieldDelegate
extension EditProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        selectedVisibleYValue = textField.frame.maxY
        return true
    }
}

//MARK:  UITextViewDelegate
extension EditProfileViewController:UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        selectedVisibleYValue = textView.frame.maxY
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print(textView.frame.maxY)
        selectedVisibleYValue = textView.frame.maxY
        let textViewToolBarHight:CGFloat = 20
        forceUpdateContentOffset(inset: textViewToolBarHight)
    }
}

//MARK:  TagsCollectionViewDelegate
extension EditProfileViewController: TagsCollectionViewDelegate {
    
    func tagTextFiledShouldReturn(tagsCollectionView: TagsCollectionView, text: String) {
        scrollView.updateContentView()
        selectedVisibleYValue = tagsCollectionView.frame.maxY
        forceUpdateContentOffset(inset: 0)
    }
    
    func tagTextFiledDidBeginEditing(tagsCollectionView: TagsCollectionView) {
        selectedVisibleYValue = tagsCollectionView.frame.maxY
    }
    
    func tagTextConstraintsDidChange(tagsCollectionView: TagsCollectionView) {
        scrollView.updateContentView()
    }
}

//MARK:  setupConstraints
extension EditProfileViewController {
    
    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        gelleryScrollView.translatesAutoresizingMaskIntoConstraints = false
        editPhotosButton.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        interestsTags.translatesAutoresizingMaskIntoConstraints = false
        desireTags.translatesAutoresizingMaskIntoConstraints = false
        aboutLabel.translatesAutoresizingMaskIntoConstraints = false
        advertTextView.translatesAutoresizingMaskIntoConstraints = false
        genderButton.translatesAutoresizingMaskIntoConstraints = false
        sexualityButton.translatesAutoresizingMaskIntoConstraints = false
        incognitoLabel.translatesAutoresizingMaskIntoConstraints = false
        incognitoAboutLabel.translatesAutoresizingMaskIntoConstraints = false
        incognitoSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(gelleryScrollView)
        scrollView.addSubview(editPhotosButton)
        scrollView.addSubview(nameLabel)
        scrollView.addSubview(nameTextField)
        scrollView.addSubview(interestsTags)
        scrollView.addSubview(desireTags)
        scrollView.addSubview(aboutLabel)
        scrollView.addSubview(advertTextView)
        scrollView.addSubview(genderButton)
        scrollView.addSubview(sexualityButton)
        scrollView.addSubview(incognitoLabel)
        scrollView.addSubview(incognitoAboutLabel)
        scrollView.addSubview(incognitoSwitch)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            gelleryScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            gelleryScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 25),
            gelleryScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            gelleryScrollView.heightAnchor.constraint(equalTo: gelleryScrollView.widthAnchor),
            
            editPhotosButton.topAnchor.constraint(equalTo: gelleryScrollView.bottomAnchor, constant: 35),
            editPhotosButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            editPhotosButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            editPhotosButton.heightAnchor.constraint(equalTo: editPhotosButton.widthAnchor, multiplier: 1.0/7.28),
            
            nameLabel.topAnchor.constraint(equalTo: editPhotosButton.bottomAnchor, constant: 35),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            nameTextField.heightAnchor.constraint(equalToConstant: 25),
            nameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            nameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            interestsTags.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 15),
            interestsTags.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            interestsTags.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            desireTags.topAnchor.constraint(equalTo: interestsTags.bottomAnchor, constant: 15),
            desireTags.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            desireTags.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            aboutLabel.topAnchor.constraint(equalTo: desireTags.bottomAnchor, constant: 35),
            aboutLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            aboutLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            advertTextView.topAnchor.constraint(equalTo: aboutLabel.bottomAnchor),
            advertTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            advertTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            genderButton.topAnchor.constraint(equalTo: advertTextView.bottomAnchor, constant: 35),
            genderButton.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            genderButton.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            genderButton.heightAnchor.constraint(equalToConstant: 70),
            
            sexualityButton.topAnchor.constraint(equalTo: genderButton.bottomAnchor, constant: 25),
            sexualityButton.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            sexualityButton.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            sexualityButton.heightAnchor.constraint(equalToConstant: 70),
            
            incognitoLabel.topAnchor.constraint(equalTo: sexualityButton.bottomAnchor, constant: 35),
            incognitoLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            incognitoLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            incognitoSwitch.topAnchor.constraint(equalTo: incognitoLabel.topAnchor),
            incognitoSwitch.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            incognitoAboutLabel.topAnchor.constraint(equalTo: incognitoSwitch.bottomAnchor, constant: 10),
            incognitoAboutLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            incognitoAboutLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -55),
        ])
    }
}

