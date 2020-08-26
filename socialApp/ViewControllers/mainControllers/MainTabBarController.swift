//
//  MainTabBarController.swift
//  socialApp
//
//  Created by Денис Щиголев on 05.07.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupControllers()
    
    }
    
    private func setupControllers(){
        
        let listVC = ListViewController()
        let peopleVC = PeopleViewController()
        
        guard let listImage = UIImage(systemName: "bubble.left.and.bubble.right.fill") else { return }
        guard let peopleImage = UIImage(systemName: "person.2.fill") else { return }
        
        tabBar.tintColor = .label
        
        viewControllers = [
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
