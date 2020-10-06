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

class SetProfileViewController: UIViewController {
    
    let profileImage = EditableProfileImageView()
    let nameLabel = UILabel(labelText: "Называй меня:",
                            textFont: .systemFont(ofSize: 16, weight: .bold))
    let aboutLabel = UILabel(labelText: "Мои желания на сегодня:",
                             textFont: .systemFont(ofSize: 16, weight: .bold))
    let sexLabel = UILabel(labelText: "Я",
                           textFont: .systemFont(ofSize: 16, weight: .regular))
    let wantLabel = UILabel(labelText: "ищу",
                            textFont: .systemFont(ofSize: 16, weight: .regular))
    let nameTextField = OneLineTextField(isSecureText: false,
                                         tag: 1,
                                         placeHoledText: "Ты можешь быть кем угодно...")
    let advertTextView = UITextView(text: "Для просмотра обьявлений других пользователей, расскажи о своих желаниях...",
                                    isEditable: true)
    
    let sexButton = UIButton(newBackgroundColor: nil,
                             borderWidth: 0,
                             title: Sex.man.rawValue,
                             titleColor: .myPurpleColor(),
                             isEnable: false)
    let wantButton = UIButton(newBackgroundColor: nil,
                              borderWidth: 0,
                              title: Want.woman.rawValue,
                              titleColor: .myPurpleColor())
    let goButton = UIButton(newBackgroundColor: .label,
                            newBorderColor: .label,
                            title: "Начнем!",
                            titleColor: .systemBackground)
    
    var delegateNavigation: AuthNavigationDelegate?
    
    private var currentPeople: MPeople?
    private var currentUser: User
    
    init(currentUser: User) {
        self.currentUser = currentUser
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
        getPeopleData()
        setupVC()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getLocation()
    }
    
    private func setupVC() {
        view.backgroundColor = .systemBackground
        advertTextView.delegate = self
        nameTextField.delegate = self
        advertTextView.addDoneButton()
    }
    
    //MARK:  setupNavigationController
    private func setupNavigationController(){
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .systemBackground
        navigationItem.title = "Профиль"
        let exitItem = UIBarButtonItem(title: "Выход", style: .plain, target: self, action: #selector(signOut))
        exitItem.tintColor = .label
        navigationItem.rightBarButtonItem = exitItem
    }
    
    //MARK:  setupButtonAction
    private func setupButtonAction() {
        goButton.addTarget(self, action: #selector(goButtonPressed), for: .touchUpInside)
        sexButton.addTarget(self, action: #selector(touchSexButton), for: .touchUpInside)
        wantButton.addTarget(self, action: #selector(touchWantButton), for: .touchUpInside)
        profileImage.plusButton.addTarget(self, action: #selector(choosePhoto), for: .touchUpInside)
    }
}

//MARK:  getPeopleData
extension SetProfileViewController {
    
    private func getPeopleData() {
        guard let email = currentUser.email else { return }
        FirestoreService.shared.getUserData(userID: email) {[weak self] result in
            switch result {
            case .success(let mPeople):
                self?.currentPeople = mPeople
                UserDefaultsService.shared.saveMpeople(people: mPeople)
                self?.setPeopleData()
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

//MARK:  setPeopleData
extension SetProfileViewController {
    
    private func setPeopleData() {
        guard let people = currentPeople else { return }
        
        if let imageURL = URL(string: people.userImage) {
            profileImage.profileImage.sd_setImage(with: imageURL, completed: nil)
        }
        
        nameTextField.text = people.displayName
        advertTextView.text = people.advert
        advertTextView.textColor = .label
        
        if people.sex == "" {
            sexButton.isEnabled = true
            sexButton.setTitle(Sex.man.rawValue, for: .normal)
        } else {
            sexButton.setTitle(people.sex, for: .normal)
        }
        
        if people.search == "" {
            wantButton.setTitle(Want.woman.rawValue, for: .normal)
        } else {
            wantButton.setTitle(people.search, for: .normal)
        }
    }
}

extension SetProfileViewController {
    //MARK:  signOut
    @objc func signOut() {
        signOutAlert()
    }
    
    //MARK:  touchSexButton
    @objc func touchSexButton() {
        switch sexButton.titleLabel?.text {
        case Sex.man.rawValue:
            FirestoreService.shared.saveGender(user: currentUser,
                                               gender: Sex.woman.rawValue) {[weak self] result in
                                                switch result {
                                                case .success():
                                                    self?.sexButton.setTitle(Sex.woman.rawValue, for: .normal)
                                                    self?.currentPeople?.sex = Sex.woman.rawValue
                                                    UserDefaultsService.shared.saveMpeople(people: self?.currentPeople)
                                                case .failure(let error):
                                                    fatalError(error.localizedDescription)
                                                }
            }
        default:
            FirestoreService.shared.saveGender(user: currentUser,
                                               gender: Sex.man.rawValue) {[weak self] result in
                                                switch result {
                                                case .success():
                                                    self?.sexButton.setTitle(Sex.man.rawValue, for: .normal)
                                                    self?.currentPeople?.sex = Sex.man.rawValue
                                                    UserDefaultsService.shared.saveMpeople(people: self?.currentPeople)
                                                case .failure(let error):
                                                    fatalError(error.localizedDescription)
                                                }
            }
        }
    }
    
    //MARK:  touchWantButton
    @objc func touchWantButton() {
        switch wantButton.titleLabel?.text {
        case Want.man.rawValue:
            FirestoreService.shared.saveWant(user: currentUser,
                                             want: Want.woman.rawValue) {[weak self] result in
                                                switch result {
                                                case .success():
                                                    self?.wantButton.setTitle(Want.woman.rawValue, for: .normal)
                                                    self?.currentPeople?.search = Want.woman.rawValue
                                                    UserDefaultsService.shared.saveMpeople(people: self?.currentPeople)
                                                case .failure(let error):
                                                    fatalError(error.localizedDescription)
                                                }
            }
            
        default:
            FirestoreService.shared.saveWant(user: currentUser,
                                             want: Want.man.rawValue) {[weak self] result in
                                                switch result {
                                                case .success():
                                                    self?.wantButton.setTitle(Want.man.rawValue, for: .normal)
                                                    self?.currentPeople?.search = Want.man.rawValue
                                                    UserDefaultsService.shared.saveMpeople(people: self?.currentPeople)
                                                case .failure(let error):
                                                    fatalError(error.localizedDescription)
                                                }
            }
        }
    }
    
    //MARK:  choosePhoto
    @objc func choosePhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        choosePhotoAlert {[weak self] sourceType in
            guard let type = sourceType else { return }
            imagePicker.sourceType = type
            self?.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    //MARK:  goButtonPressed
    @objc func goButtonPressed() {
        let name = nameTextField.text ?? ""
        //MARK: NEED ADD VALIDATE zTO TEXT ADVERT
        let advert = advertTextView.text ?? ""

        FirestoreService.shared.saveAdvertAndName(user: currentUser,
                                                  userName: name,
                                                  advert: advert,
                                                  isActive: true) {[weak self] result in
                                                    switch result {
                                                    case .success():
                                                        self?.currentPeople?.advert = advert
                                                        self?.currentPeople?.displayName = name
                                                        self?.currentPeople?.isActive = true
                                                        UserDefaultsService.shared.saveMpeople(people: self?.currentPeople)
                                                        self?.tabBarController?.selectedIndex = 1
                                                        
                                                    case .failure(let error):
                                                        fatalError(error.localizedDescription)
                                                    }
        }
    }
}

extension SetProfileViewController {
    //MARK: getLocation
    private func getLocation() {
        if let userID = currentUser.email {
            LocationService.shared.getCoordinate(userID: userID) {[weak self] isAllowPermission in
                //if geo is denied, show alert and go to settings
                if isAllowPermission == false {
                    self?.openSettingsAlert()
                }
            }
        }
    }
}

extension SetProfileViewController {
    //MARK:  signOutAlert
    private func signOutAlert() {
        let alert = UIAlertController(title: nil,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        let okAction = UIAlertAction(title: "Выйду, но вернусь",
                                     style: .destructive) { _ in
            
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
//MARK:  UITextFieldDelegate
extension SetProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
//MARK:  UITextViewDelegate
extension SetProfileViewController:UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxSymbols = 2000
        let existingLines = textView.text.components(separatedBy: CharacterSet.newlines)
        let newLines = text.components(separatedBy: CharacterSet.newlines)
        let linesAfterChange = existingLines.count + newLines.count - 1
        if(text == "\n") {
            if linesAfterChange <= textView.textContainer.maximumNumberOfLines {
                return true
            } else {
                textView.resignFirstResponder()
                return false
            }
        }
        
        let newLine = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let characterCount = newLine.count
        if characterCount <= maxSymbols {
            return true
        } else {
            textView.resignFirstResponder()
            return false
        }
    }
}

//MARK:  UIImagePickerControllerDelegate

extension SetProfileViewController:UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        profileImage.profileImage.image = image
        FirestoreService.shared.saveAvatar(image: image, user: currentUser) {[weak self] result in
            switch result {
            case .success(let userImageString):
                self?.currentPeople?.userImage = userImageString
                UserDefaultsService.shared.saveMpeople(people: self?.currentPeople)
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
}

//MARK: touchBegan
extension SetProfileViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }
}

//MARK:  setupConstraints
extension SetProfileViewController {
    
    private func setupConstraints() {
        
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutLabel.translatesAutoresizingMaskIntoConstraints = false
        sexLabel.translatesAutoresizingMaskIntoConstraints = false
        wantLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        advertTextView.translatesAutoresizingMaskIntoConstraints = false
        sexButton.translatesAutoresizingMaskIntoConstraints = false
        wantButton.translatesAutoresizingMaskIntoConstraints = false
        goButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(profileImage)
        view.addSubview(nameLabel)
        view.addSubview(aboutLabel)
        view.addSubview(sexLabel)
        view.addSubview(wantLabel)
        view.addSubview(nameTextField)
        view.addSubview(advertTextView)
        view.addSubview(sexButton)
        view.addSubview(wantButton)
        view.addSubview(goButton)
        
        NSLayoutConstraint.activate([
            
            profileImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            profileImage.widthAnchor.constraint(equalToConstant: self.view.frame.width / 4),
            profileImage.heightAnchor.constraint(equalTo: profileImage.widthAnchor, multiplier: 1/1),
            
            nameTextField.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 45),
            nameTextField.heightAnchor.constraint(equalToConstant: 25),
            nameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            nameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            nameLabel.bottomAnchor.constraint(equalTo: nameTextField.topAnchor, constant: -5),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            advertTextView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 45),
            advertTextView.bottomAnchor.constraint(equalTo: sexLabel.topAnchor, constant: 20),
            advertTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            advertTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            aboutLabel.bottomAnchor.constraint(equalTo: advertTextView.topAnchor, constant: 0),
            aboutLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            aboutLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            sexLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            sexLabel.bottomAnchor.constraint(equalTo: goButton.topAnchor, constant: -25),
            
            sexButton.leadingAnchor.constraint(equalTo: sexLabel.trailingAnchor, constant: 5),
            sexButton.bottomAnchor.constraint(equalTo: goButton.topAnchor, constant: -25),
            sexButton.heightAnchor.constraint(equalToConstant: 22),
            
            wantLabel.leadingAnchor.constraint(equalTo: sexButton.trailingAnchor, constant: 5),
            wantLabel.bottomAnchor.constraint(equalTo: goButton.topAnchor, constant: -25),
            
            wantButton.leadingAnchor.constraint(equalTo: wantLabel.trailingAnchor, constant: 5),
            wantButton.bottomAnchor.constraint(equalTo: goButton.topAnchor, constant: -25),
            wantButton.heightAnchor.constraint(equalToConstant: 22),
            
            goButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            goButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            goButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            goButton.heightAnchor.constraint(equalTo: goButton.widthAnchor, multiplier: 1.0/7.28)
        ])
    }
}

