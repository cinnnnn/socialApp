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
    
    weak var acceptChatsDelegate: AcceptChatsDelegate?
    weak var requestChatsDelegate: RequestChatDelegate?
    weak var peopleListenerDelegate: PeopleListenerDelegate?
    
    init(userID: String) {
        self.userID = userID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPeopleData()
    }
}

extension MainTabBarController {
    //MARK: getPeopleData, location
    private func getPeopleData() {
        FirestoreService.shared.getUserData(userID: userID) {[weak self] result in
            switch result {
            case .success(let mPeople):
                UserDefaultsService.shared.saveMpeople(people: mPeople)
                if let location = MVirtualLocation(rawValue: mPeople.searchSettings[MSearchSettings.currentLocation.rawValue] ?? 0) {
                    switch location{
                    case .current:
                        //get current location
                        LocationService.shared.getCoordinate(userID: mPeople.senderId) {[weak self] isAllowPermission in
                            //if geo is denied, show alert and go to settings
                            if isAllowPermission == false {
                                
                                self?.openSettingsAlert()
                            }
                            //close loading animation
                            self?.setupControllers(currentPeople: mPeople)
                        }
                    default:
                        //people use custom location, just reloadData
                        //close loading animation
                        self?.setupControllers(currentPeople: mPeople)
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
        
        let profileVC = ProfileViewController(currentPeople: currentPeople)
        let peopleVC = PeopleViewController(currentPeople: currentPeople)
        let requsetsVC = RequestsViewController(currentPeople: currentPeople)
        let chatsVC = ChatsViewController(currentPeople: currentPeople)
        
        peopleListenerDelegate = peopleVC
        requestChatsDelegate = requsetsVC
        acceptChatsDelegate = chatsVC
        
        //setup delegate
        peopleVC.requestDelegate = requestChatsDelegate
        peopleVC.acceptChatsDelegate = acceptChatsDelegate
        profileVC.peopleListnerDelegate = peopleListenerDelegate
        
        viewControllers = [
            generateNavigationController(rootViewController: peopleVC, image: #imageLiteral(resourceName: "people"), title: nil, isHidden: true),
            generateNavigationController(rootViewController: requsetsVC, image: #imageLiteral(resourceName: "Heart"), title: nil, isHidden: true),
            generateNavigationController(rootViewController: chatsVC, image: #imageLiteral(resourceName: "chats"), title: nil),
            generateNavigationController(rootViewController: profileVC, image: #imageLiteral(resourceName: "profile"), title: nil)
        ]
    }
    
    
    private func generateNavigationController(rootViewController: UIViewController,
                                              image: UIImage,
                                              title: String?,
                                              isHidden: Bool = false) -> UIViewController {
        
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.imageInsets = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        navController.tabBarItem.image = image
        
        navController.navigationItem.title = title
        navController.navigationBar.isHidden = isHidden
        
        navController.navigationBar.prefersLargeTitles = true
        navController.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.tintColor = .myLabelColor()
        navController.navigationBar.barTintColor = .myWhiteColor()
        navController.navigationBar.isTranslucent = true
        navController.navigationBar.backgroundColor = .myWhiteColor()
        navController.navigationBar.titleTextAttributes = [.font: UIFont.avenirBold(size: 16)]
        navController.navigationBar.largeTitleTextAttributes = [.font: UIFont.avenirBold(size: 38)]
        return navController
    }
}


extension MainTabBarController {
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
