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
    
    private var currentPeople: MPeople?
    var currentUser: User!

    
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
        
        let listVC = ListViewController(currentUser: currentUser )
        let peopleVC = PeopleViewController(currentUser: currentUser)
        let setProfileVC = SetProfileViewController(currentUser: currentUser)
        
        guard let listImage = UIImage(systemName: "bubble.left.and.bubble.right.fill") else { return }
        guard let peopleImage = UIImage(systemName: "person.2.fill") else { return }
        
        tabBar.tintColor = .label
        
        viewControllers = [
            generateNavigationController(rootViewController: setProfileVC, image: listImage, title: "Профиль"),
            generateNavigationController(rootViewController: peopleVC, image: peopleImage, title: "Объявления"),
            generateNavigationController(rootViewController: listVC, image: listImage, title: "Чаты")
            
        ]
    }
    
    
    private func generateNavigationController(rootViewController: UIViewController,
                                              image: UIImage,
                                              title: String) -> UIViewController {
        
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = image
        navController.tabBarItem.title = title
        
        return navController
    }
    
}
