//
//  ViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 26.06.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI
import FirebaseAuth
import AuthenticationServices
import Lottie

class AuthViewController: UIViewController {
    
    let loginButton = UIButton(newBackgroundColor: nil,
                               title: "Войти с Email",
                               titleColor: .myGrayColor(),
                               font: .avenirRegular(size: 16))
    
    let appleButton = ASAuthorizationAppleIDButton()
    let logoImage = UIImageView(image: #imageLiteral(resourceName: "Logo"), contentMode: .scaleAspectFit)
    var animatedLogoImage = AnimationCustomView(name: "communication", loopMode: .loop, contentMode: .scaleAspectFit)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConstraints()
        setupVC()
        setupButtonAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        appleButton.cornerRadius = appleButton.frame.height / 2
        
    }
    
    //MARK:  setupVC
    private func setupVC() {
        view.backgroundColor = .myWhiteColor()
        appleButton.layoutIfNeeded()
        
        animatedLogoImage.animationView.play()
    }
    
    //MARK:  setupButtonAction
    private func setupButtonAction() {
        loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(appleButtonPressed), for: .touchUpInside)
    }
    
    //MARK:  objc func
    @objc func loginButtonPressed() {
        let navController = UINavigationController.init(rootViewController: LoginViewController(navigationDelegate: self))
        let appearance = navController.navigationBar.standardAppearance
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        appearance.backgroundImage = UIImage()
        appearance.backgroundColor = .myWhiteColor()
        navController.navigationBar.standardAppearance = appearance
        
        
        navController.modalPresentationStyle = .fullScreen
        navController.navigationBar.isHidden = true
        navController.navigationBar.tintColor = .myLabelColor()
        navController.modalTransitionStyle = .crossDissolve
       present(navController, animated: true, completion: nil)
    }
    
    @objc func appleButtonPressed() {
        AuthService.shared.AppleIDRequest(delegateController: self,
                                          presetationController: self)
    }
}

//MARK:  ASWebAuthenticationPresentationContextProviding
extension AuthViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = self.view.window else { fatalError("can't get window")}
        return window
    }
}

//MARK:  ASAuthorizationControllerDelegate
extension AuthViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        AuthService.shared.didCompleteWithAuthorizationApple(authorization: authorization) {  [weak self] result in
            
            switch result {
            
            //if success get credential, then auth
            case .success(let credential):
                AuthService.shared.signInApple(with: credential) { result in
                    switch result {
                    
                    case .success(let user):
                        //if success Apple login renew or create base mPeople info
                        FirestoreService.shared.saveBaseProfile(id: user.email!,
                                                                email: user.email!,
                                                                authType: .appleID) { result in
                            switch result {
                            
                            case .success(let id):
                                //subscribe to notification topics
                                PushMessagingService.shared.subscribeMainTopic(userID: id)
                                //check mPeople data for next VC
                                FirestoreService.shared.getUserData(userID: id) { result in
                                    switch result {
                                    
                                    case .success(let mPeople):
                                        //check gender and want data in mPeople
                                        if mPeople.userImage == "" {
                                            self?.toCompliteRegistration(userID: mPeople.senderId)
                                        } else {
                                            self?.toMainTabBarController(currentPeople: mPeople)
                                        }
                                    case .failure(_):
                                        break
                                    }
                                }
                            //Error saveBase Info
                            case .failure(let error):
                                fatalError(error.localizedDescription)
                            }
                        }
                    //Error Apple login
                    case .failure(let error):
                        fatalError(error.localizedDescription)
                       // self?.appleSignInAlerController()
                    }
                }
            //Error get credential for Apple Auth
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
}

//MARK:   alertController
extension AuthViewController {
    
    private func appleSignInAlerController() {
        let alert = UIAlertController(title: "Проблемы со входом",
                                      message: "Что то с твоим AppleID пошло не так",
                                      preferredStyle: .actionSheet)
        let actionMail = UIAlertAction(title: "Войти по Email",
                                       style: .default) { _ in
                                        self.loginButtonPressed()
        }
        let actionRetry = UIAlertAction(title: "Попробовать еще раз AppleID",
                                        style: .default) { _ in
                                            self.appleButtonPressed()
        }
        let actionCancel = UIAlertAction(title: "Отмена, надо подумать",
                                         style: .destructive, handler: nil)
        
        alert.addAction(actionMail)
        alert.addAction(actionRetry)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: navigationDelegate
extension AuthViewController: NavigationDelegate {
    
    func toMainTabBarController(currentPeople: MPeople){
        let mainTabBarVC = MainTabBarController(currentUser: currentPeople, isNewLogin: true)
        mainTabBarVC.modalPresentationStyle = .fullScreen
        mainTabBarVC.modalTransitionStyle = .crossDissolve
        present(mainTabBarVC, animated: false, completion: nil)
    }
    
    func toCompliteRegistration(userID: String){
        print("111")
        let navController = UINavigationController.init(rootViewController: DateOfBirthViewController(userID: userID))
        let appearance = navController.navigationBar.standardAppearance
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear
        appearance.backgroundImage = UIImage()
        appearance.backgroundColor = .myWhiteColor()
        navController.navigationBar.standardAppearance = appearance
        
        navController.navigationBar.tintColor = .myLabelColor()
        navController.modalPresentationStyle = .fullScreen
        navController.modalTransitionStyle = .crossDissolve
        navController.navigationBar.prefersLargeTitles = false
        present(navController, animated: false, completion: nil)
    }
}
// MARK:  Setup Constraints
extension AuthViewController {
    private func setupConstraints(){
      
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(animatedLogoImage)
        view.addSubview(loginButton)
        view.addSubview(appleButton)
        
        animatedLogoImage.anchor(leading: view.leadingAnchor,
                         trailing: view.trailingAnchor,
                         top: view.safeAreaLayoutGuide.topAnchor,
                         bottom: loginButton.topAnchor,
                         padding: .init(top: 25, left: 0, bottom: 10, right: 0))
        
        appleButton.anchor(leading: view.leadingAnchor,
                           trailing: view.trailingAnchor,
                           top: nil,
                           bottom: view.safeAreaLayoutGuide.bottomAnchor,
                           height: appleButton.widthAnchor,
                           multiplier: .init(width: 0, height: 1.0/7.28),
                           padding: .init(top: 0, left: 25, bottom: 25, right: 25))
        
        loginButton.anchor(leading: view.leadingAnchor,
                           trailing: view.trailingAnchor,
                           top: nil,
                           bottom: appleButton.topAnchor,
                           height: loginButton.widthAnchor,
                           multiplier: .init(width: 0, height: 1.0/7.28),
                           padding: .init(top: 0, left: 25, bottom: 10, right: 25))
        
       
        
    }
}
