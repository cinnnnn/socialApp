//
//  SceneDelegate.swift
//  socialApp
//
//  Created by Денис Щиголев on 26.06.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import FirebaseAuth
import ApphudSDK

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        if let user = Auth.auth().currentUser {
            //try reload, to check profile is avalible on server
            user.reload {[weak self] error in
                if let _ = error {
                    //if profile don't avalible, log out
                    AuthService.shared.signOut { result in
                        switch result {
                        case .success(_):
                            Apphud.logout()
                            UserDefaultsService.shared.deleteMpeople()
                            self?.window?.rootViewController = self?.makeRootVC(viewController: AuthViewController(), withNavContoller: true)
                            
                        case .failure(let error):
                            fatalError(error.localizedDescription)
                        }
                    }
                } else {
                    if let userID = user.email {
                        //if user avalible, go to main controller
                        self?.window?.rootViewController = MainTabBarController(userID: userID,
                                                                                isNewLogin: false)
                    }
                }
            }
        } else {
           //if don't have avalible current auth in firebase, set root authVc
            window?.rootViewController = makeRootVC(viewController: AuthViewController(), withNavContoller: true)
        }
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        UserDefaults.extensions.badge = 0
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}


extension SceneDelegate {
    
    private func makeRootVC(viewController: UIViewController, withNavContoller: Bool = false) -> UIViewController {
        
        if withNavContoller {
            let navVC = UINavigationController(rootViewController: viewController)
            navVC.navigationBar.isHidden = true
            navVC.navigationItem.backButtonTitle = "Войти с Apple ID"
            return navVC
        }
        return viewController
    }
    
    private func checkProfileInfo(user: User, complition:@escaping(Result<Bool,Error>) -> Void){
        
        FirestoreService.shared.getUserData(userID: user.uid) { result in
            switch result {
            
            case .success(let mPeople):
                if mPeople.gender == "" || mPeople.lookingFor == "" {
                    complition(.success(true))
                } else {
                    complition(.success(false))
                }
                
            //error of getUserData
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
}

