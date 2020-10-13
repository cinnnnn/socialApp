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
                            textFont: .avenirRegular(size: 16),
                            textColor: .myGrayColor())
    let aboutLabel = UILabel(labelText: "Обо мне:",
                             textFont: .avenirRegular(size: 16),
                             textColor: .myGrayColor())
    let sexLabel = UILabel(labelText: "Пол:",
                           textFont: .avenirRegular(size: 16),
                           textColor: .myGrayColor())
    let wantLabel = UILabel(labelText: "Ищу:",
                            textFont: .avenirRegular(size: 16),
                            textColor: .myGrayColor())
    let nameTextField = OneLineTextField(isSecureText: false,
                                         tag: 1,
                                         placeHoledText: "Ты можешь быть кем угодно...")
    let advertTextView = UITextView(text: "Для просмотра обьявлений других пользователей, расскажи о себе...",
                                    isEditable: true)
    
  
    let editPhotosButton = UIButton(newBackgroundColor: .label,
                                    newBorderColor: .label,
                                    title: "Редактировать фото",
                                    titleColor: .systemBackground)
    
    
    private var currentPeople: MPeople?
    
    deinit {
        print(#function)
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        gelleryScrollView.prepareReuseScrollView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.updateContentView()
    }
    
    private func setupVC() {
        view.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true
        scrollView.addSingleTapRecognizer(target: self, selector: #selector(endEditing))
        
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
        exitItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -10, right: -10)
        navigationItem.rightBarButtonItem = exitItem
    }
    
    //MARK:  setupButtonAction
    private func setupButtonAction() {
        editPhotosButton.addTarget(self, action: #selector(editPhotosButtonTap), for: .touchUpInside)
      
    }
}


extension SetProfileViewController {
    //MARK:  setPeopleData
    private func setPeopleData() {
        
        guard let people = UserDefaultsService.shared.getMpeople() else { return }
        currentPeople = people
        
        gelleryScrollView.setupImages(imagesURL: [people.userImage] + people.gallery) {
            self.gelleryScrollView.layoutSubviews()
        }
        
        
        nameTextField.text = people.displayName
        advertTextView.text = people.advert
        advertTextView.textColor = .label
        

    }
    
    //MARK:  savePeopleData
    private func savePeopleData() {
        let name = nameTextField.text ?? ""
        let advert = advertTextView.text ?? ""
        
        guard var people = currentPeople else { return }
        
        FirestoreService.shared.saveAdvertAndName(id: people.senderId,
                                                  userName: name,
                                                  advert: advert,
                                                  isActive: true) { result in
            switch result {
            case .success():
                people.advert = advert
                people.displayName = name
                people.isActive = true
                UserDefaultsService.shared.saveMpeople(people: people)
                
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
}


//MARK: NotificationCenter
extension SetProfileViewController {
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
extension SetProfileViewController {
    
    @objc func editPhotosButtonTap() {
        let vc = EditPhotoViewController()
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
    
    //MARK: updateView
    @objc func updateView(notification: Notification) {
        let info = notification.userInfo
        guard let keyboardSize = info?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let size = keyboardSize.cgRectValue
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            view.frame.origin.y = -size.height
        }
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            view.frame.origin.y = 0
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
        editPhotosButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(gelleryScrollView)
        scrollView.addSubview(nameLabel)
        scrollView.addSubview(aboutLabel)
        scrollView.addSubview(sexLabel)
        scrollView.addSubview(wantLabel)
        scrollView.addSubview(nameTextField)
        scrollView.addSubview(advertTextView)
        scrollView.addSubview(editPhotosButton)
        
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
            
            nameTextField.topAnchor.constraint(equalTo: editPhotosButton.bottomAnchor, constant: 45),
            nameTextField.heightAnchor.constraint(equalToConstant: 25),
            nameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            nameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
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
            
        ])
    }
}

