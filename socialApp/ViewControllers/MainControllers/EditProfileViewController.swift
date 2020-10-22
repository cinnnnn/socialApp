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
    let gelleryScrollView = GalleryScrollView(imagesURL: [])
    let nameLabel = UILabel(labelText: "Вымышленное имя:",
                            textFont: .avenirRegular(size: 16),
                            textColor: .myGrayColor())
    let aboutLabel = UILabel(labelText: "Обо мне:",
                             textFont: .avenirRegular(size: 16),
                             textColor: .myGrayColor())
    let genderButton = OneLineButton(header: "Гендер", info: "")
    let sexualityButton = OneLineButton(header: "Сексуальная ориентация", info: "")
    let lookingForButton = OneLineButton(header: "Ищу", info: "")
    let nameTextField = OneLineTextField(isSecureText: false,
                                         tag: 1,
                                         placeHoledText: "Ты можешь быть кем угодно...")
    let advertTextView = UITextView(text: "Для просмотра обьявлений других пользователей, расскажи о себе...",
                                    isEditable: true)
    
    let editPhotosButton = RoundButton(newBackgroundColor: .myFirstButtonColor(),
                                       title: "Редактировать фото",
                                       titleColor: .myFirstButtonLabelColor())
    
    let exitProfileButton = RoundButton(newBackgroundColor: .mySecondButtonColor(),
                                        title: "Выйти из профиля",
                                        titleColor: .mySecondButtonLabelColor())
    
    private var visibleRect: CGPoint?
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
        setupNavigationController()
        setupConstraints()
        setupButtonAction()
        setupVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerNotificationForKeyboard()
        setPeopleData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotificationForKeyboard()
        savePeopleData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.updateContentView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        gelleryScrollView.prepareReuseScrollView()
    }

    private func setupVC() {
        view.backgroundColor = .systemBackground
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        scrollView.addSingleTapRecognizer(target: self, selector: #selector(endEditing))
        advertTextView.delegate = self
        nameTextField.delegate = self
        gelleryScrollView.clipsToBounds = true
        advertTextView.addDoneButton()
        editPhotosButton.layoutIfNeeded()
        exitProfileButton.layoutIfNeeded()
        scrollView.layoutIfNeeded()
    }
    
    //MARK:  setupNavigationController
    private func setupNavigationController(){
        navigationItem.title = "Профиль"
        navigationItem.backButtonTitle = ""
    }
    
    //MARK:  setupButtonAction
    private func setupButtonAction() {
        editPhotosButton.addTarget(self, action: #selector(editPhotosButtonTap), for: .touchUpInside)
        exitProfileButton.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        genderButton.addTarget(self, action: #selector(genderSelectTapped), for: .touchUpInside)
        sexualityButton.addTarget(self, action: #selector(sexualitySelectTapped), for: .touchUpInside)
        lookingForButton.addTarget(self, action: #selector(sexualitySelectTapped), for: .touchUpInside)
    }
}


extension EditProfileViewController {
    //MARK:  setPeopleData
    private func setPeopleData() {
        
        guard let people = UserDefaultsService.shared.getMpeople() else { return }
        currentPeople = people
        
        gelleryScrollView.setupImages(imagesURL: [people.userImage] + people.gallery) {
            self.gelleryScrollView.layoutSubviews()
        }
        
        nameTextField.text = people.displayName
        advertTextView.text = people.advert
        genderButton.infoLabel.text = people.gender
        sexualityButton.infoLabel.text = people.sexuality
        lookingForButton.infoLabel.text = people.lookingFor

    }
    
    //MARK:  savePeopleData
    private func savePeopleData() {
        let name = nameTextField.text ?? ""
        let advert = advertTextView.text ?? ""
        let id = currentPeople.senderId
        
        guard let gender = genderButton.infoLabel.text else { fatalError("Can't get gender from button")}
        guard let sexuality = sexualityButton.infoLabel.text else { fatalError("Can't get sexuality from button")}
        guard let lookingFor = lookingForButton.infoLabel.text else { fatalError("Can't get lookingFor from button")}
        FirestoreService.shared.saveProfileAfterEdit(id: id,
                                                     name: name,
                                                     advert: advert,
                                                     gender: gender,
                                                     sexuality: sexuality,
                                                     lookingFor: lookingFor) { result in
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
    private func registerNotificationForKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateView(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateView(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func removeNotificationForKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

//MARK: objc extension
extension EditProfileViewController {
    
    @objc func editPhotosButtonTap() {
        let id = currentPeople.senderId
        let vc = EditPhotoViewController(userID: id,isFirstSetup: false)
        navigationController?.pushViewController(vc, animated: true)
    }

    //MARK:  signOut
    @objc func signOut() {
        signOutAlert()
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
    
    //MARK: lookingForSelectTapped
    @objc private func lookingForSelectTapped() {
        let vc = SelectionViewController(elements: MLookingFor.modelStringAllCases,
                                         description: MLookingFor.description,
                                         selectedValue: lookingForButton.infoLabel.text ?? "",
                                         complition: { [weak self] selected in
                                            self?.lookingForButton.infoLabel.text = selected
                                         })
        vc.modalPresentationStyle = .overCurrentContext
        
        present(vc, animated: true, completion: nil)
    }
    
    //MARK: updateView
    @objc func updateView(notification: Notification) {
        let info = notification.userInfo
        guard let keyboardSize = info?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let size = keyboardSize.cgRectValue
        
        if notification.name == UIResponder.keyboardWillShowNotification {
         
        guard let rect = visibleRect else { return }
            let scrollValue  = rect.y - size.minY / 2
            let scrollPoint = CGPoint(x: 0, y: scrollValue)
            scrollView.setContentOffset(scrollPoint, animated: true)
        }
        
        if notification.name == UIResponder.keyboardWillHideNotification {
           // view.frame.origin.y = 0
        }
    }
}

extension EditProfileViewController {
    //MARK:  signOutAlert
    private func signOutAlert() {
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
                                         style: .default)
        
        alert.setMyStyle()
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}
//MARK:  UITextFieldDelegate
extension EditProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        visibleRect = textField.frame.origin
        return true
    }
}

//MARK:  UITextViewDelegate
extension EditProfileViewController:UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        visibleRect = textView.frame.origin
        return true
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
        aboutLabel.translatesAutoresizingMaskIntoConstraints = false
        advertTextView.translatesAutoresizingMaskIntoConstraints = false
        genderButton.translatesAutoresizingMaskIntoConstraints = false
        lookingForButton.translatesAutoresizingMaskIntoConstraints = false
        sexualityButton.translatesAutoresizingMaskIntoConstraints = false
        exitProfileButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(gelleryScrollView)
        scrollView.addSubview(editPhotosButton)
        scrollView.addSubview(nameLabel)
        scrollView.addSubview(nameTextField)
        scrollView.addSubview(aboutLabel)
        scrollView.addSubview(advertTextView)
        scrollView.addSubview(genderButton)
        scrollView.addSubview(lookingForButton)
        scrollView.addSubview(sexualityButton)
        scrollView.addSubview(exitProfileButton)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            gelleryScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            gelleryScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 25),
            gelleryScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            gelleryScrollView.heightAnchor.constraint(equalTo: gelleryScrollView.widthAnchor),
            
            editPhotosButton.topAnchor.constraint(equalTo: gelleryScrollView.bottomAnchor, constant: 25),
            editPhotosButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            editPhotosButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            editPhotosButton.heightAnchor.constraint(equalTo: editPhotosButton.widthAnchor, multiplier: 1.0/7.28),
            
            nameLabel.topAnchor.constraint(equalTo: editPhotosButton.bottomAnchor, constant: 25),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            nameTextField.heightAnchor.constraint(equalToConstant: 25),
            nameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            nameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            aboutLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 25),
            aboutLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            aboutLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            advertTextView.topAnchor.constraint(equalTo: aboutLabel.bottomAnchor),
            advertTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            advertTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            genderButton.topAnchor.constraint(equalTo: advertTextView.bottomAnchor, constant: 25),
            genderButton.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            genderButton.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            genderButton.heightAnchor.constraint(equalToConstant: 70),
            
            sexualityButton.topAnchor.constraint(equalTo: genderButton.bottomAnchor, constant: 15),
            sexualityButton.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            sexualityButton.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            sexualityButton.heightAnchor.constraint(equalToConstant: 70),
            
            lookingForButton.topAnchor.constraint(equalTo: sexualityButton.bottomAnchor, constant: 15),
            lookingForButton.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            lookingForButton.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            lookingForButton.heightAnchor.constraint(equalToConstant: 70),
            
            exitProfileButton.topAnchor.constraint(equalTo: lookingForButton.bottomAnchor, constant: 20),
            exitProfileButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            exitProfileButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            exitProfileButton.heightAnchor.constraint(equalTo: exitProfileButton.widthAnchor, multiplier: 1.0/7.28),
        ])
    }
}

