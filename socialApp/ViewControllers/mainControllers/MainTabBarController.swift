//
//  MainTabBarController.swift
//  socialApp
//
//  Created by Денис Щиголев on 05.07.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import FirebaseAuth

class MainTabBarController: UITabBarController {
    
    var currentUser: User!
    var peopleVC: UIViewController?
    
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    //only for swiftUI
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupControllers()
    
    }
    
    private func setupControllers(){
        tabBar.barTintColor = .myWhiteColor()
        
        let listVC = ChatsViewController(currentUser: currentUser )
        let profileVC = ProfileViewController(currentUser: currentUser)
        let peopleVC = PeopleViewController(currentUser: currentUser)
        
        tabBar.tintColor = .label
        
        viewControllers = [
            generateNavigationController(rootViewController: profileVC, image: #imageLiteral(resourceName: "profile"), title: nil),
            generateNavigationController(rootViewController: peopleVC, image: #imageLiteral(resourceName: "people"), title: nil, isHidden: true),
            generateNavigationController(rootViewController: listVC, image: #imageLiteral(resourceName: "chats"), title: nil, isHidden: true)
        ]
    }
    
    
    private func generateNavigationController(rootViewController: UIViewController,
                                              image: UIImage,
                                              title: String?,
                                              isHidden: Bool = false) -> UIViewController {
        
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.imageInsets = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        navController.tabBarItem.image = image

        navController.navigationBar.isHidden = isHidden
        navController.navigationBar.backgroundColor = .systemBackground
        navController.navigationItem.title = title
        
        return navController
    }
}
