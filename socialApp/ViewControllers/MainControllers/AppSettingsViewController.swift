//
//  AppSettingsViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 27.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import FirebaseAuth
import AuthenticationServices
import SDWebImage
import FirebaseMessaging
import ApphudSDK

class AppSettingsViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<SectionAppSettings, MAppSettings>?
    private var currentPeople: MPeople
    weak var acceptChatDelegate: AcceptChatListenerDelegate?
    weak var requestChatDelegate: RequestChatListenerDelegate?
    
    init(currentPeople: MPeople,
         acceptChatDelegate: AcceptChatListenerDelegate?,
         requestChatDelegate: RequestChatListenerDelegate?) {
        
        self.acceptChatDelegate = acceptChatDelegate
        self.requestChatDelegate = requestChatDelegate
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationController()
    }
    
    private func setup() {
        view.backgroundColor = .myWhiteColor()
    }
    
    //MARK:  setupNavigationController
    private func setupNavigationController(){
        navigationItem.title = "Настройки"
        navigationItem.backButtonTitle = ""
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

extension AppSettingsViewController {
    //MARK: deleteAllUserData
    private func deleteAllUserData() {
        FirestoreService.shared.deleteAllProfileData(userID: currentPeople.senderId) { [weak self] in
            //after delete, sign out
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
                let vc = AboutViewController()
                navigationController?.pushViewController(vc, animated: true)
                collectionView.deselectItem(at: indexPath, animated: true)
                
            case .logOut:
                signOutAlert(pressedIndexPath: indexPath)
            case .terminateAccaunt:
                terminateAccauntAlert(pressedIndexPath: indexPath)
            }
        }
    }
}

//MARK: - ALERTS
extension AppSettingsViewController {
    //MARK:  signOutAlert
    private func signOutAlert(pressedIndexPath: IndexPath) {
        guard let acceptChatDelegate = acceptChatDelegate else { return }
        let strongCurrentPeople = currentPeople
        
        let alert = UIAlertController(title: nil,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        let okAction = UIAlertAction(title: "Выйду, но вернусь",
                                     style: .destructive) {[weak self] _ in
            
            self?.view.addCustomTransition(type: .fade)
            AuthService.shared.signOut { result in
                switch result {
                case .success(_):
                    
                    Apphud.logout()
                    UserDefaultsService.shared.deleteMpeople()
                    PushMessagingService.shared.logOutUnsabscribe(currentUserID: strongCurrentPeople.senderId,
                                                                  acceptChats: acceptChatDelegate.acceptChats)
                case .failure(let error):
                    fatalError(error.localizedDescription)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Продолжу общение",
                                         style: .default) { [weak self] _ in
            self?.collectionView.deselectItem(at: pressedIndexPath, animated: true)
        }
        
        alert.setMyLightStyle()
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK:  terminateAccauntAlert
    private func terminateAccauntAlert(pressedIndexPath: IndexPath) {
        
        let alert = UIAlertController(title: nil,
                                      message: "Удалить профиль полностью, без возможности восстановления?",
                                      preferredStyle: .actionSheet)
        
        let okAction = UIAlertAction(title: "Ввести пароль и удалить",
                                     style: .destructive) {[weak self] _ in
            
            let authType = self?.currentPeople.authType
            
            switch authType {
            case .appleID:
                AuthService.shared.AppleIDRequest(delegateController: self!,
                                                  presetationController: self!)
            case .email:
                self?.emailLoginAlert()
            case .none:
                return
            }
        }
        
        let cancelAction = UIAlertAction(title: "Продолжу общение",
                                         style: .default) { [weak self] _ in
            self?.collectionView.deselectItem(at: pressedIndexPath, animated: true)
        }
        
        alert.setMyLightStyle()
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK:  emailLoginAlert
    private func emailLoginAlert() {
        let strongCurrentPeople = currentPeople
        guard let acceptChatDelegate = acceptChatDelegate else { return }
        
        let alert = UIAlertController(title: "Введи свой пароль от почты:",
                                      message: currentPeople.mail,
                                      preferredStyle: .alert)

        let actionOK = UIAlertAction(title: "Подтвердить",
                                     style: .cancel) {[weak self] _ in
            
            guard let password = alert.textFields?.first?.text else { return }
            guard let mail = self?.currentPeople.mail else { return }
            
            AuthService.shared.reAuthentificate(credential: nil,
                                                email: mail,
                                                password: password) { result in
                switch result {
                
                case .success(_):
                    self?.deleteAllUserData()
                    Apphud.logout()
                    PushMessagingService.shared.logOutUnsabscribe(currentUserID: strongCurrentPeople.senderId,
                                                                  acceptChats: acceptChatDelegate.acceptChats)
                case .failure(let error):
                    self?.reAuthErrorAlert(text: error.localizedDescription)
                }
            }
        }
        
        alert.addTextField { passwordTextField in
            passwordTextField.isSecureTextEntry = true
            passwordTextField.tag = 1
            passwordTextField.delegate = self
        }
        
        alert.setMyLightStyle()
        alert.addAction(actionOK)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:  reAuthAlert
    private func reAuthErrorAlert(text: String) {
        let alert = UIAlertController(title: "Ошибка",
                                      message: text,
                                      preferredStyle: .actionSheet)
        let actionCancel = UIAlertAction(title: "Хорошо",
                                         style: .cancel, handler: nil)
        
        alert.setMyLightStyle()
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: UITextFieldDelegate
extension AppSettingsViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.selectAll(nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField, nextField.isEnabled {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        return false
    }
}

//MARK: - AppleID Auth
extension AppSettingsViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = self.view.window else { fatalError("can't get window")}
        return window
    }
}

//MARK:  ASAuthorizationControllerDelegate
extension AppSettingsViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard let acceptChatDelegate = acceptChatDelegate else { return }
        let strongCurrentPeople = currentPeople
        
        AuthService.shared.didCompleteWithAuthorizationApple(authorization: authorization) {  [weak self] result in
            
            switch result {
            
            //if success get credential, then auth
            case .success(let credential):
                
                AuthService.shared.reAuthentificate(credential: credential, email: nil, password: nil) { result in
                    switch result {
                    
                    case .success(_):
                        //after reAuth, delete all user data
                        PushMessagingService.shared.logOutUnsabscribe(currentUserID: strongCurrentPeople.senderId,
                                                                      acceptChats: acceptChatDelegate.acceptChats)
                        self?.deleteAllUserData()
                        UserDefaultsService.shared.deleteMpeople()
                        Apphud.logout()
                    case .failure(let error):
                        self?.reAuthErrorAlert(text: error.localizedDescription)
                    }
                }
            //Error get credential for Apple Auth
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
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


