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
    
    let scrollView = UIScrollView()
    let gelleryScrollView = GalleryScrollView(imagesURL: [])
    let nameLabel = UILabel(labelText: "Вымышленное имя:",
                            textFont: .systemFont(ofSize: 16, weight: .bold))
    let aboutLabel = UILabel(labelText: "Обо мне:",
                             textFont: .systemFont(ofSize: 16, weight: .bold))
    let sexLabel = UILabel(labelText: "Пол",
                           textFont: .systemFont(ofSize: 16, weight: .regular))
    let wantLabel = UILabel(labelText: "ищу",
                            textFont: .systemFont(ofSize: 16, weight: .regular))
    let nameTextField = OneLineTextField(isSecureText: false,
                                         tag: 1,
                                         placeHoledText: "Ты можешь быть кем угодно...")
    let advertTextView = UITextView(text: "Для просмотра обьявлений других пользователей, расскажи о себе...",
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
    let editPhotoButton = UIButton(newBackgroundColor: .label,
                            newBorderColor: .label,
                            title: "Редактировать фото",
                            titleColor: .systemBackground)

    
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
        setPeopleData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.updateContentView()

    }
    
   
    private func setupVC() {
        view.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true
        
        advertTextView.delegate = self
        nameTextField.delegate = self
        advertTextView.addDoneButton()
    }
    
    //MARK:  setupNavigationController
    private func setupNavigationController(){
        
        navigationController?.navigationBar.barTintColor = .myWhiteColor()
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Редактирование"
        let exitItem = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(signOut))
        exitItem.image = #imageLiteral(resourceName: "exit")
        exitItem.imageInsets = UIEdgeInsets(top: 0, left: 5, bottom: -10, right: -10)
        navigationItem.rightBarButtonItem = exitItem
    }
    
    //MARK:  setupButtonAction
    private func setupButtonAction() {
        editPhotoButton.addTarget(self, action: #selector(goButtonPressed), for: .touchUpInside)
        sexButton.addTarget(self, action: #selector(touchSexButton), for: .touchUpInside)
        wantButton.addTarget(self, action: #selector(touchWantButton), for: .touchUpInside)
    }
}

//MARK:  setPeopleData
extension SetProfileViewController {
    
    private func setPeopleData() {
        
        if let imageURL = URL(string: currentPeople.userImage) {
            gelleryScrollView.setupImages(imagesURL: [imageURL]) {
                self.gelleryScrollView.layoutSubviews()
            }
        }
        
        nameTextField.text = currentPeople.displayName
        advertTextView.text = currentPeople.advert
        advertTextView.textColor = .label
        
        if currentPeople.sex == "" {
            sexButton.isEnabled = true
            sexButton.setTitle(Sex.man.rawValue, for: .normal)
        } else {
            sexButton.setTitle(currentPeople.sex, for: .normal)
        }
        
        if currentPeople.search == "" {
            wantButton.setTitle(Want.woman.rawValue, for: .normal)
        } else {
            wantButton.setTitle(currentPeople.search, for: .normal)
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
            FirestoreService.shared.saveGender(id: currentPeople.senderId,
                                               gender: Sex.woman.rawValue) {[weak self] result in
                                                switch result {
                                                case .success():
                                                    self?.sexButton.setTitle(Sex.woman.rawValue, for: .normal)
                                                    self?.currentPeople.sex = Sex.woman.rawValue
                                                    UserDefaultsService.shared.saveMpeople(people: self?.currentPeople)
                                                case .failure(let error):
                                                    fatalError(error.localizedDescription)
                                                }
            }
        default:
            FirestoreService.shared.saveGender(id: currentPeople.senderId,
                                               gender: Sex.man.rawValue) {[weak self] result in
                                                switch result {
                                                case .success():
                                                    self?.sexButton.setTitle(Sex.man.rawValue, for: .normal)
                                                    self?.currentPeople.sex = Sex.man.rawValue
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
            FirestoreService.shared.saveWant(id: currentPeople.senderId,
                                             want: Want.woman.rawValue) {[weak self] result in
                                                switch result {
                                                case .success():
                                                    self?.wantButton.setTitle(Want.woman.rawValue, for: .normal)
                                                    self?.currentPeople.search = Want.woman.rawValue
                                                    UserDefaultsService.shared.saveMpeople(people: self?.currentPeople)
                                                case .failure(let error):
                                                    fatalError(error.localizedDescription)
                                                }
            }
            
        default:
            FirestoreService.shared.saveWant(id: currentPeople.senderId,
                                             want: Want.man.rawValue) {[weak self] result in
                                                switch result {
                                                case .success():
                                                    self?.wantButton.setTitle(Want.man.rawValue, for: .normal)
                                                    self?.currentPeople.search = Want.man.rawValue
                                                    UserDefaultsService.shared.saveMpeople(people: self?.currentPeople)
                                                case .failure(let error):
                                                    fatalError(error.localizedDescription)
                                                }
            }
        }
    }
    
//    //MARK:  choosePhoto
//    @objc func choosePhoto() {
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        choosePhotoAlert {[weak self] sourceType in
//            guard let type = sourceType else { return }
//            imagePicker.sourceType = type
//            self?.present(imagePicker, animated: true, completion: nil)
//        }
//    }
    
    //MARK:  goButtonPressed
    @objc func goButtonPressed() {
        let name = nameTextField.text ?? ""
        //MARK: NEED ADD VALIDATE zTO TEXT ADVERT
        let advert = advertTextView.text ?? ""
        

//        FirestoreService.shared.saveAdvertAndName(id: currentPeople.senderId,
//                                                  userName: name,
//                                                  advert: advert,
//                                                  isActive: true) {[weak self] result in
//                                                    switch result {
//                                                    case .success():
//                                                        self?.currentPeople.advert = advert
//                                                        self?.currentPeople.displayName = name
//                                                        self?.currentPeople.isActive = true
//                                                        UserDefaultsService.shared.saveMpeople(people: self?.currentPeople)
//                                                        self?.tabBarController?.selectedIndex = 1
//
//                                                    case .failure(let error):
//                                                        fatalError(error.localizedDescription)
//                                                    }
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
}

//MARK:  UIImagePickerControllerDelegate

//extension SetProfileViewController:UIImagePickerControllerDelegate , UINavigationControllerDelegate{
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//        picker.dismiss(animated: true, completion: nil)
//        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
//        profileImage.profileImage.image = image
//        FirestoreService.shared.saveAvatar(image: image, id: currentPeople.senderId) {[weak self] result in
//            switch result {
//            case .success(let userImageString):
//                self?.currentPeople.userImage = userImageString
//                UserDefaultsService.shared.saveMpeople(people: self?.currentPeople)
//            case .failure(let error):
//                fatalError(error.localizedDescription)
//            }
//        }
//    }
//}

//MARK: touchBegan
extension SetProfileViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }
}

//MARK:  setupConstraints
extension SetProfileViewController {
    
    private func setupConstraints() {
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        gelleryScrollView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutLabel.translatesAutoresizingMaskIntoConstraints = false
        sexLabel.translatesAutoresizingMaskIntoConstraints = false
        wantLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        advertTextView.translatesAutoresizingMaskIntoConstraints = false
        sexButton.translatesAutoresizingMaskIntoConstraints = false
        wantButton.translatesAutoresizingMaskIntoConstraints = false
        editPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(gelleryScrollView)
        scrollView.addSubview(nameLabel)
        scrollView.addSubview(aboutLabel)
        scrollView.addSubview(sexLabel)
        scrollView.addSubview(wantLabel)
        scrollView.addSubview(nameTextField)
        scrollView.addSubview(advertTextView)
        scrollView.addSubview(sexButton)
        scrollView.addSubview(wantButton)
        scrollView.addSubview(editPhotoButton)
        
        NSLayoutConstraint.activate([
            
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            gelleryScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            gelleryScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 25),
            gelleryScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            gelleryScrollView.heightAnchor.constraint(equalTo: gelleryScrollView.widthAnchor),
            
            editPhotoButton.topAnchor.constraint(equalTo: gelleryScrollView.bottomAnchor, constant: 25),
            editPhotoButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            editPhotoButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            editPhotoButton.heightAnchor.constraint(equalTo: editPhotoButton.widthAnchor, multiplier: 1.0/7.28),
            
            nameTextField.topAnchor.constraint(equalTo: editPhotoButton.bottomAnchor, constant: 45),
            nameTextField.heightAnchor.constraint(equalToConstant: 25),
            nameTextField.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 25),
            nameTextField.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -25),
            
            nameLabel.bottomAnchor.constraint(equalTo: nameTextField.topAnchor, constant: -5),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            advertTextView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 45),
            advertTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            advertTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            aboutLabel.bottomAnchor.constraint(equalTo: advertTextView.topAnchor, constant: 0),
            aboutLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            aboutLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            sexLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            sexLabel.topAnchor.constraint(equalTo: advertTextView.bottomAnchor, constant: 25),
            
            sexButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            sexButton.topAnchor.constraint(equalTo: sexLabel.bottomAnchor, constant: 5),
            sexButton.heightAnchor.constraint(equalToConstant: 22),
            
            wantLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            wantLabel.topAnchor.constraint(equalTo: sexButton.bottomAnchor, constant: 25),
            
            wantButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            wantButton.topAnchor.constraint(equalTo: wantLabel.bottomAnchor, constant: 5),
            wantButton.heightAnchor.constraint(equalToConstant: 22),
        ])
    }
}

