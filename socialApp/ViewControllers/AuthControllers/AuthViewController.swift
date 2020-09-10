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
                               titleColor: .myHeaderColor(),
                               font: .systemFont(ofSize: 16, weight: .regular),
                               isShadow: false)
    
    let appleButton = ASAuthorizationAppleIDButton()
    
    let logoImage = UIImageView(image: #imageLiteral(resourceName: "Logo"), contentMode: .scaleAspectFit)
    
    let loginVC = LoginViewController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVC()
        setupConstraints()
        setupButtonAction()
    }
    
}

//MARK: - setupVC
extension AuthViewController {
    
    private func setupVC() {
        view.backgroundColor = .systemBackground
    
        loginVC.delegate = self
    }
}

//MARK: - setupButtonAction
extension AuthViewController {
    
    private func setupButtonAction() {
        loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(appleButtonPressed), for: .touchUpInside)
    }
}

//MARK: - objc func
extension AuthViewController {
    
    
    @objc func loginButtonPressed() {
        present(loginVC, animated: true, completion: nil)
        
    }
    
    @objc func appleButtonPressed() {
        AuthService.shared.AppleIDRequest(delegateController: self,
                                          presetationController: self)
    }
}

//MARK: - ASWebAuthenticationPresentationContextProviding
extension AuthViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let window = self.view.window else { fatalError("can't get window")}
        return window
    }
    
}

//MARK: - ASAuthorizationControllerDelegate
extension AuthViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        AuthService.shared.didCompleteWithAuthorizationApple(authorization: authorization) {  [weak self] result in
            switch result {
                
            case .success(let user):
                FirestoreService.shared.getUserData(user: user) { resultOfFirestore in
                    switch resultOfFirestore {
                        
                    case .success(let mPeople):
                        //if all section info complited, go to chats
                        self?.toMainTabBar(currentMPeople: mPeople)
                    case .failure(_):
                        self?.toSetProfile(user: user)
                    }
                }
            case .failure(_):
                self?.appleSignInAlerController()
            }
            
        }
    }
}
//MARK: - AuthNavigationDelegate
extension AuthViewController: AuthNavigationDelegate {
    
    func toMainTabBar(currentMPeople: MPeople) {
        let mainTabBarCont = MainTabBarController(currentPeople: currentMPeople)
        mainTabBarCont.modalPresentationStyle = .fullScreen
        
        present(mainTabBarCont, animated: true, completion: nil)
    }
    
    func toSetProfile(user: User) {
        let vc = SetProfileViewController(currentUser: user)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    func toLogin() {
        present(loginVC, animated: true, completion: nil)
    }
    
    func toRegister(email: String?) {
        let signUpVc = SignUpViewController(email: email)
        signUpVc.delegate = self
        present(signUpVc, animated: true, completion: nil)
    }
}


//MARK: -  alertController
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

// MARK: - Setup Constraints

extension AuthViewController {
    private func setupConstraints(){
        
        logoImage.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(logoImage)
        logoImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25).isActive = true
        logoImage.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25).isActive = true
        logoImage.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25).isActive = true
        logoImage.heightAnchor.constraint(equalTo: logoImage.widthAnchor, multiplier: 1.0/1.0).isActive = true
        
        let buttonStackView = UIStackView(arrangedSubviews: [ appleButton, loginButton ])
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 10
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(buttonStackView)
        
        buttonStackView.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 30).isActive = true
        buttonStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25).isActive = true
        buttonStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25).isActive = true
        
        appleButton.heightAnchor.constraint(equalTo: appleButton.widthAnchor, multiplier: 1.0/7.28).isActive = true
        
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
