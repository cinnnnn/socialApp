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

class AuthViewController: UIViewController {
        
    let loginButton = UIButton(newBackgroundColor: .systemBackground,
                               borderWidth: 0,
                               title: "Войти с Email",
                               titleColor: .myGrayColor(),
                               font: .systemFont(ofSize: 16, weight: .regular),
                               isShadow: false)
    
    let appleButton = ASAuthorizationAppleIDButton()
    let logoImage = UIImageView(image: #imageLiteral(resourceName: "Logo"), contentMode: .scaleAspectFit)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        setupConstraints()
        setupButtonAction()
    }
    
    //MARK:  setupVC
    private func setupVC() {
        view.backgroundColor = .systemBackground
    }
    
    //MARK:  setupButtonAction
    private func setupButtonAction() {
        loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(appleButtonPressed), for: .touchUpInside)
    }
    
    private func toGenderSelect(user: User){
        let navController = UINavigationController.init(rootViewController: GenderSelectionViewController(currentUser: user))
        navController.modalPresentationStyle = .fullScreen
        navController.navigationBar.backgroundColor = .systemBackground
        navController.navigationBar.prefersLargeTitles = true
        present(navController, animated: true, completion: nil)
    }
    
    private func toMainTabBar(user: User){
        let mainTabBarVC = MainTabBarController(currentUser: user)
        mainTabBarVC.modalPresentationStyle = .fullScreen
        present(mainTabBarVC, animated: true, completion: nil)
    }
    
    //MARK:  objc func
    @objc func loginButtonPressed() {
        let navController = UINavigationController.init(rootViewController: LoginViewController())
        navController.modalPresentationStyle = .fullScreen
        navController.navigationBar.isHidden = true
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
                                                                email: user.email!) { result in
                                                                    //check mPeople data for next VC
                            FirestoreService.shared.getUserData(userID: user.email!) { result in
                                                                        switch result {
                                                                        
                                                                        case .success(let mPeople):
                                                                            //check gender and want data in mPeople
                                                                            if mPeople.sex == "" || mPeople.search == "" {
                                                                                self?.toGenderSelect(user: user)
                                                                            } else {
                                                                                self?.toMainTabBar(user: user)
                                                                            }
                                                                        case .failure(_):
                                                                             break
                                                                        }
                                                                    }
                        }
                    //Error Apple login
                    case .failure(_):
                        self?.appleSignInAlerController()
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
        let alert = UIAlertController(title: "Проблемки со входом",
                                      message: "Что то с твоим AppleID пошло не так",
                                      preferredStyle: .actionSheet)
        let actionMail = UIAlertAction(title: "Попробовать по почте",
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

// MARK:  Setup Constraints
extension AuthViewController {
    private func setupConstraints(){
        
        let buttonStackView = UIStackView(arrangedSubviews: [ appleButton, loginButton ])
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 10
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
      
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(logoImage)
        view.addSubview(buttonStackView)
        
        logoImage.anchor(leading: view.leadingAnchor,
                         trailing: view.trailingAnchor,
                         top: view.safeAreaLayoutGuide.topAnchor,
                         bottom: nil,
                         height: logoImage.widthAnchor,
                         padding: .init(top: 25, left: 25, bottom: 0, right: 25))
        
        buttonStackView.anchor(leading: logoImage.leadingAnchor,
                               trailing: logoImage.trailingAnchor,
                               top: logoImage.bottomAnchor,
                               bottom: nil,
                               padding: .init(top: 25, left: 0, bottom: 0, right: 0))
        
        appleButton.anchor(leading: nil,
                           trailing: nil,
                           top: nil,
                           bottom: nil,
                           height: appleButton.widthAnchor,
                           multiplier: .init(width: 0, height: 1.0/7.28))
        
    }
}

//MARK: - SwiftUI
struct ViewControllerProvider: PreviewProvider {
    
    static var previews: some View {
        ContenerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContenerView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: Context) -> AuthViewController {
            AuthViewController()
        }
        
        func updateUIViewController(_ uiViewController: AuthViewController, context: Context) {
            
        }
    }
}
