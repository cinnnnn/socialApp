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
    var firstLoadService: FirstLoadService
    
    init(currentUser: MPeople, isNewLogin: Bool) {
        self.isNewLogin = isNewLogin
        self.currentUser = currentUser
        self.firstLoadService = FirstLoadService(currentUser: currentUser)
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
        setup()
        setupControllers()
    }
}

extension MainTabBarController {
    private func setup() {
        if isNewLogin {
            PopUpService.shared.showAnimateView(name: "loading_square")
        }
        view.backgroundColor = .myWhiteColor()
    }
}


//MARK: setupControllers
extension MainTabBarController {
    private func setupControllers(){
        firstLoadService.loadData { updatedPeople,
                                    acceptChatsDelegate,
                                    requestChatsDelegate,
                                    peopleDelegate,
                                    likeDislikeDelegate,
                                    messageDelegate,
                                    reportsDelegate in
            
            PopUpService.shared.dismisPopUp(name: MAnimamationName.loading.rawValue) { [unowned self] in
                
                let appearance = tabBar.standardAppearance.copy()
                appearance.backgroundImage = UIImage()
                appearance.shadowImage = UIImage()
                appearance.shadowColor = .clear
                appearance.backgroundColor = .myWhiteColor()
                tabBar.standardAppearance = appearance
                
                tabBar.unselectedItemTintColor = .myLightGrayColor()
                tabBar.tintColor = .myLabelColor()
                
                let profileVC = ProfileViewController(currentPeople: updatedPeople,
                                                      peopleListnerDelegate: peopleDelegate,
                                                      likeDislikeDelegate: likeDislikeDelegate,
                                                      acceptChatsDelegate: acceptChatsDelegate,
                                                      requestChatsDelegate: requestChatsDelegate,
                                                      reportsDelegate: reportsDelegate)
                
                let peopleVC = PeopleViewController(currentPeople: updatedPeople,
                                                    peopleDelegate: peopleDelegate,
                                                    requestChatDelegate: requestChatsDelegate,
                                                    likeDislikeDelegate: likeDislikeDelegate,
                                                    acceptChatDelegate: acceptChatsDelegate,
                                                    reportDelegate: reportsDelegate)
                
                peopleDelegate.peopleCollectionViewDelegate = peopleVC
                
                let requsetsVC = RequestsViewController(currentPeople: updatedPeople,
                                                        likeDislikeDelegate: likeDislikeDelegate,
                                                        requestChatDelegate: requestChatsDelegate,
                                                        peopleNearbyDelegate: peopleDelegate,
                                                        acceptChatDelegate: acceptChatsDelegate,
                                                        reportDelegate: reportsDelegate)
                
                requestChatsDelegate.requestChatCollectionViewDelegate = requsetsVC
                
                let chatsVC = ChatsViewController(currentPeople: updatedPeople,
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
        }
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


