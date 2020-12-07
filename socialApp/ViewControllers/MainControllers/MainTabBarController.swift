//
//  MainTabBarController.swift
//  socialApp
//
//  Created by Денис Щиголев on 05.07.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import FirebaseAuth
import ApphudSDK

class MainTabBarController: UITabBarController{
    
    var currentUser: MPeople
    var isNewLogin: Bool
  //  let loadingView = LoadingView(name: "explore", isHidden: false)
    var acceptChatsDelegate: AcceptChatListenerDelegate?
    var requestChatsDelegate: RequestChatListenerDelegate?
    var peopleDelegate: PeopleListenerDelegate?
    var likeDislikeDelegate: LikeDislikeListenerDelegate?
    var messageDelegate: MessageListenerDelegate?
    var reportsDelegate: ReportsListnerDelegate?
    
    init(currentUser: MPeople, isNewLogin: Bool) {
        self.isNewLogin = isNewLogin
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deinit main tabbar")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getPeopleData()
        setupApphud()
    }
}

extension MainTabBarController {
    private func setupDataDelegate(complition: @escaping ()-> Void) {
        likeDislikeDelegate = LikeDislikeChatDataProvider(userID: currentUser.senderId)
        requestChatsDelegate = RequestChatDataProvider(userID: currentUser.senderId)
        acceptChatsDelegate = AcceptChatDataProvider(userID: currentUser.senderId)
        peopleDelegate = PeopleDataProvider(userID: currentUser.senderId)
        messageDelegate = MessagesDataProvider(userID: currentUser.senderId)
        reportsDelegate = ReportsDataProvider(userID: currentUser.senderId)
        
        PopUpService.shared.setupDelegate(acceptChatsDelegate: acceptChatsDelegate,
                                          requestChatsDelegate: requestChatsDelegate,
                                          peopleDelegate: peopleDelegate,
                                          likeDislikeDelegate: likeDislikeDelegate,
                                          messageDelegate: messageDelegate,
                                          reportsDelegate: reportsDelegate)
        
        complition()
    }
    
    private func subscribeToPushNotification() {
        //subscribe to all pushNotification from chats after relogin
        if isNewLogin {
            guard let acceptChatsDelegate = acceptChatsDelegate else { return }
            PushMessagingService.shared.logInSubscribe(currentUserID: currentUser.senderId,
                                                       acceptChats: acceptChatsDelegate.acceptChats)
        }
    }
    
    private func loadIsComplite(isComplite: Bool) {
        tabBar.isHidden = !isComplite
        if isComplite {
            //stop load animation animation
            PopUpService.shared.dismisAllPopUp()
        }
    }
    
    private func setupApphud() {
        Apphud.start(apiKey: "app_LDXecjNbEuvUBtpd3J9kw75A6cH14n", userID: currentUser.senderId, observerMode: false)
    }
}

extension MainTabBarController {
    //MARK: getPeopleData, location
    private func getPeopleData() {
        //if new login, show animation loading pop up, else we already start show animation in SceneDelegate
        if isNewLogin {
            PopUpService.shared.showAnimateView(name: "loading_square")
        }
        setupDataDelegate { [weak self] in
            guard let currentUser = self?.currentUser else { fatalError("can't get current user") }
            guard let reportDelegate = self?.reportsDelegate else { fatalError("reportDelegate is nil") }
            
            UserDefaultsService.shared.saveMpeople(people: currentUser)
            if let virtualLocation = MVirtualLocation(rawValue: currentUser.searchSettings[MSearchSettings.currentLocation.rawValue] ?? 0) {
                LocationService.shared.getCoordinate(userID: currentUser.senderId,
                                                     virtualLocation: virtualLocation) {[weak self] isAllowPermission in
                    //if geo is denied, show alert and go to settings
                    if !isAllowPermission {
                        self?.openSettingsAlert()
                    }
                    //get like users
                    self?.likeDislikeDelegate?.getLike(complition: { result in
                        switch result {
                        
                        case .success(_):
                            
                            //get dislike users
                            self?.likeDislikeDelegate?.getDislike(complition: { result in
                                switch result {
                                
                                case .success(_):
                                    
                                    //get reports
                                    self?.reportsDelegate?.getReports(complition: { result in
                                        switch result {
                                        
                                        case .success(_):
                                            
                                            //get request users
                                            self?.requestChatsDelegate?.getRequestChats(reportsDelegate: reportDelegate,
                                                                                        complition: { result in
                                                switch result {
                                                
                                                case .success(_):
                                                    //get accept chats
                                                    self?.acceptChatsDelegate?.getAcceptChats(complition: {[weak self] result in
                                                        switch result {
                                                        
                                                        case .success(_):
                                                            //check active subscribtion
                                                            PurchasesService.shared.checkSubscribtion(currentPeople: currentUser) { result in
                                                                
                                                                switch result {
                                                                //if check success, load Controllers with status updated people
                                                                case .success(let updatedPeople):
                                                                    self?.setupControllers(currentPeople: updatedPeople)
                                                                //if check failure, load Controllers with previus premium status people
                                                                case .failure(_):
                                                                    self?.setupControllers(currentPeople: currentUser)
                                                                }
                                                                self?.subscribeToPushNotification()
                                                                
                                                            }
                                                            
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
                        case .failure(let error):
                            self?.showAlert(title: "Ошибка, мы работаем над ней",
                                            text: error.localizedDescription,
                                            buttonText: "Попробую позже")
                        }
                    })
                }
            }
        }
    }
}


//MARK: setupControllers
extension MainTabBarController {
    private func setupControllers(currentPeople: MPeople){
        let appearance = tabBar.standardAppearance.copy()
        appearance.backgroundImage = UIImage()
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .myWhiteColor()
        tabBar.standardAppearance = appearance
        
        tabBar.unselectedItemTintColor = .myLightGrayColor()
        tabBar.tintColor = .myLabelColor()
        
        guard let likeDislikeDelegate = likeDislikeDelegate else { fatalError("likeDislike is nil")}
        guard let requestChatsDelegate = requestChatsDelegate else { fatalError("requestChatsDelegate is nil")}
        guard let peopleDelegate = peopleDelegate else { fatalError("peopleDelegate is nil")}
        guard let acceptChatsDelegate = acceptChatsDelegate else { fatalError("acceptChatsDelegate is nil")}
        guard let reportsDelegate = reportsDelegate else { fatalError("reportsDelegate is nil")}
        guard let messageDelegate = messageDelegate else { fatalError("messageDelegate is nil")}
        
        let profileVC = ProfileViewController(currentPeople: currentPeople,
                                              peopleListnerDelegate: peopleDelegate,
                                              likeDislikeDelegate: likeDislikeDelegate,
                                              acceptChatsDelegate: acceptChatsDelegate,
                                              requestChatsDelegate: requestChatsDelegate,
                                              reportsDelegate: reportsDelegate)
        
        let peopleVC = PeopleViewController(currentPeople: currentPeople,
                                            peopleDelegate: peopleDelegate,
                                            requestChatDelegate: requestChatsDelegate,
                                            likeDislikeDelegate: likeDislikeDelegate,
                                            acceptChatDelegate: acceptChatsDelegate,
                                            reportDelegate: reportsDelegate)
        
        peopleDelegate.peopleCollectionViewDelegate = peopleVC
        
        let requsetsVC = RequestsViewController(currentPeople: currentPeople,
                                                likeDislikeDelegate: likeDislikeDelegate,
                                                requestChatDelegate: requestChatsDelegate,
                                                peopleNearbyDelegate: peopleDelegate,
                                                acceptChatDelegate: acceptChatsDelegate,
                                                reportDelegate: reportsDelegate)
        
        requestChatsDelegate.requestChatCollectionViewDelegate = requsetsVC
        
        let chatsVC = ChatsViewController(currentPeople: currentPeople,
                                          acceptChatDelegate: acceptChatsDelegate,
                                          likeDislikeDelegate: likeDislikeDelegate,
                                          messageDelegate: messageDelegate,
                                          requestChatsDelegate: requestChatsDelegate,
                                          peopleDelegate: peopleDelegate,
                                          reportDelegate: reportsDelegate)
        
        acceptChatsDelegate.acceptChatCollectionViewDelegate = chatsVC
        
        
        viewControllers = [
            generateNavigationController(rootViewController: peopleVC, image: #imageLiteral(resourceName: "people"), title: nil, isHidden: true),
            generateNavigationController(rootViewController: requsetsVC, image: #imageLiteral(resourceName: "request"), title: nil, isHidden: true),
            generateNavigationController(rootViewController: chatsVC, image: #imageLiteral(resourceName: "chats"), title: nil),
            generateNavigationController(rootViewController: profileVC, image: #imageLiteral(resourceName: "profile"), title: nil, isHidden: true)
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
        
        let appereance = navController.navigationBar.standardAppearance.copy()
        appereance.shadowImage = UIImage()
        appereance.shadowColor = .clear
        appereance.backgroundImage = UIImage()
        appereance.backgroundColor = .myWhiteColor()
        
        navController.navigationBar.standardAppearance = appereance
        navController.navigationBar.prefersLargeTitles = false
        navController.navigationBar.tintColor = .myLabelColor()
        
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

