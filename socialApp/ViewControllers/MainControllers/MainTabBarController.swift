//
//  MainTabBarController.swift
//  socialApp
//
//  Created by Денис Щиголев on 05.07.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import FirebaseAuth

class MainTabBarController: UITabBarController{
    
    var userID: String
    let loadingView = LoadingView(isHidden: false)
    
    var acceptChatsDelegate: AcceptChatListenerDelegate?
    var requestChatsDelegate: RequestChatListenerDelegate?
    var peopleDelegate: PeopleListenerDelegate?
    var likeDislikeDelegate: LikeDislikeListenerDelegate?
    
    init(userID: String) {
        self.userID = userID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        loadIsComplite(isComplite: false)
        setupDataDelegate()
        getPeopleData()
    }
}

extension MainTabBarController {
    private func setupDataDelegate() {
        likeDislikeDelegate = LikeDislikeChatDataProvider(userID: userID)
        requestChatsDelegate = RequestChatDataProvider(userID: userID)
        acceptChatsDelegate = AcceptChatDataProvider(userID: userID)
        peopleDelegate = PeopleDataProvider(userID: userID)
    }
    
    private func loadIsComplite(isComplite: Bool) {
        tabBar.isHidden = !isComplite
        if isComplite {
            loadingView.hide()
        } else {
            loadingView.show()
        }
    }
}

extension MainTabBarController {
    //MARK: getPeopleData, location
    private func getPeopleData() {
        FirestoreService.shared.getUserData(userID: userID) {[weak self] result in
            switch result {
            case .success(let mPeople):
                UserDefaultsService.shared.saveMpeople(people: mPeople)
                if let virtualLocation = MVirtualLocation(rawValue: mPeople.searchSettings[MSearchSettings.currentLocation.rawValue] ?? 0) {
                    LocationService.shared.getCoordinate(userID: mPeople.senderId,
                                                         virtualLocation: virtualLocation) {[weak self] isAllowPermission in
                        //if geo is denied, show alert and go to settings
                        if !isAllowPermission {
                            self?.openSettingsAlert()
                        }
                        //get like like users
                        self?.likeDislikeDelegate?.getLike(complition: { result in
                            switch result {
                            
                            case .success(_):
                                //get dislike users
                                self?.likeDislikeDelegate?.getDislike(complition: { result in
                                    switch result {
                                
                                    case .success(_):
                                        //get request users
                                        self?.requestChatsDelegate?.getRequestChats(complition: { result in
                                            switch result {
                                            
                                            case .success(_):
                                                //get accept chats
                                                self?.acceptChatsDelegate?.getAcceptChats(complition: { result in
                                                    switch result {
                                                    
                                                    case .success(_):
                                                        self?.loadIsComplite(isComplite: true)
                                                        self?.setupControllers(currentPeople: mPeople)
                                                        
                                                    case .failure(let error):
                                                        self?.showAlert(title: "Ошибка, мы работаем над ней",
                                                                        text: error.localizedDescription,
                                                                        buttonText: "Попробую позже")
                                                    }
                                                })
                                                
                                            case .failure(let error):
                                                self?.showAlert(title: "Ошибка, мы работаем над ней",
                                                                text: error.localizedDescription,
                                                                buttonText: "Попробую позже")
                                            }
                                        })
                                        
                                    case .failure(let error):
                                        self?.showAlert(title: "Ошибка, мы работаем над ней",
                                                        text: error.localizedDescription,
                                                        buttonText: "Попробую позже")
                                    }
                                })
                            case .failure(let error):
                                self?.showAlert(title: "Ошибка, мы работаем над ней",
                                                text: error.localizedDescription,
                                                buttonText: "Попробую позже")
                            }
                        })
                    }
                }
                
            case .failure(_):
                //if get incorrect info from mPeople profile, logOut and go to authVC
                AuthService.shared.signOut { result in
                    switch result {
                    case .success(_):
                        self?.dismiss(animated: true) {
                            let authVC = AuthViewController()
                            authVC.modalPresentationStyle = .fullScreen
                            authVC.modalTransitionStyle = .crossDissolve
                            self?.present(authVC, animated: false, completion: nil)
                        }
                        
                    case .failure(let error):
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
    }
}



//MARK: setupControllers
extension MainTabBarController {
    private func setupControllers(currentPeople: MPeople){
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        tabBar.barTintColor = .myWhiteColor()
        tabBar.unselectedItemTintColor = .myLightGrayColor()
        tabBar.tintColor = .myLabelColor()
        
        let profileVC = ProfileViewController(currentPeople: currentPeople,
                                              peopleListnerDelegate: peopleDelegate,
                                              likeDislikeDelegate: likeDislikeDelegate,
                                              acceptChatsDelegate: acceptChatsDelegate)
        
        let peopleVC = PeopleViewController(currentPeople: currentPeople,
                                            peopleDelegate: peopleDelegate,
                                            requestChatDelegate: requestChatsDelegate,
                                            likeDislikeDelegate: likeDislikeDelegate,
                                            acceptChatDelegate: acceptChatsDelegate)
        
        peopleDelegate?.peopleCollectionViewDelegate = peopleVC
        
        let requsetsVC = RequestsViewController(currentPeople: currentPeople,
                                                likeDislikeDelegate: likeDislikeDelegate,
                                                requestChatDelegate: requestChatsDelegate,
                                                peopleNearbyDelegate: peopleDelegate,
                                                acceptChatDelegate: acceptChatsDelegate)
        
        requestChatsDelegate?.requestChatCollectionViewDelegate = requsetsVC
        
        let chatsVC = ChatsViewController(currentPeople: currentPeople,
                                          acceptChatDelegate: acceptChatsDelegate,
                                          likeDislikeDelegate: likeDislikeDelegate)
        
        acceptChatsDelegate?.acceptChatCollectionViewDelegate = chatsVC
        
        
        viewControllers = [
            generateNavigationController(rootViewController: peopleVC, image: #imageLiteral(resourceName: "people"), title: nil, isHidden: true),
            generateNavigationController(rootViewController: requsetsVC, image: #imageLiteral(resourceName: "Heart"), title: nil),
            generateNavigationController(rootViewController: chatsVC, image: #imageLiteral(resourceName: "chats"), title: nil),
            generateNavigationController(rootViewController: profileVC, image: #imageLiteral(resourceName: "profile"), title: nil)
        ]
    }
    
    //MARK: generateNavigationController
    private func generateNavigationController(rootViewController: UIViewController,
                                              image: UIImage,
                                              title: String?,
                                              isHidden: Bool = false,
                                              withoutBackImage: Bool = false) -> UIViewController {
        
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.imageInsets = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        navController.tabBarItem.image = image
        
        navController.navigationItem.title = title
        navController.navigationBar.isHidden = isHidden
        
        if withoutBackImage {
            navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        }
        
        navController.navigationBar.prefersLargeTitles = true
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.tintColor = .myLabelColor()
        navController.navigationBar.barTintColor = .myWhiteColor()
       // navController.navigationBar.backgroundColor = .myWhiteColor()
        navController.navigationBar.titleTextAttributes = [.font: UIFont.avenirBold(size: 16)]
        navController.navigationBar.largeTitleTextAttributes = [.font: UIFont.avenirBold(size: 38)]
        return navController
    }
}

//MARK: alert
extension MainTabBarController {
    
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
        alert.setMyLightStyle()
        present(alert, animated: true, completion: nil)
    }
    
    private func showAlert(title: String, text: String, buttonText: String) {
        
        let alert = UIAlertController(title: title,
                                      text: text,
                                      buttonText: buttonText,
                                      style: .alert)
        
        alert.setMyLightStyle()
        present(alert, animated: true, completion: nil)
    }
}

extension MainTabBarController {
    private func setupConstraints() {
        view.addSubview(loadingView)
        
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
