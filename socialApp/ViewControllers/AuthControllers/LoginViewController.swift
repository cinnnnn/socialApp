//
//  LoginViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 02.07.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI

class LoginViewController: UIViewController {
    
    let signInLogo = UIImageView(image: #imageLiteral(resourceName: "SignInLogo"),
                                 contentMode: .scaleAspectFit)
    
    let appleButton = UIButton(image: #imageLiteral(resourceName: "SignInApple"))
    
    let loginButton = UIButton(newBackgroundColor: .label,
                               newBorderColor: .label,
                               title: "Вход",
                               titleColor: .systemBackground)
    
    let signUpButton = UIButton(newBackgroundColor: .systemBackground,
                               newBorderColor: .label,
                               title: "Зарегистрироваться",
                               titleColor: .label)
    
    let emailTextField = OneLineTextField(isSecureText: false)
    let passwordTextField = OneLineTextField(isSecureText: true)
    
    let emailLabel = UILabel(labelText: "Email")
    let passwordLabel = UILabel(labelText: "Пароль")
    let needAccountLabel = UILabel(labelText: "Еще не с нами?")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVC()
        setupConstraints()
        setupButtonAction()
    }
}


//MARK: - setupVC
extension LoginViewController {
    
    private func setupVC() {
        view.backgroundColor = .systemBackground
        
    }
}
//MARK: - setupButtonAction
extension LoginViewController {
    
    private func setupButtonAction() {
        
        signUpButton.addTarget(self, action: #selector(signUpButtonPressed), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(appleButtonPressed), for: .touchUpInside)
    }
}

//MARK: - objc action
extension LoginViewController {
    
    @objc func appleButtonPressed() {
        
    }
    
    
    @objc func loginButtonPressed() {
        
        AuthService.shared.signIn(email: emailTextField.text,
                                  password: passwordTextField.text) {[weak self] result in
                                    switch result {
                                        
                                    case .success(let user):
                                        print("userName")
                                        if let userName = user.displayName {
                                            
                                            self?.showAlert(title: "Вход выполнен",
                                                            text: userName,
                                                            buttonText: "Начнем")
                                        }
                                    case .failure(let eror):
                                        let myError = eror.localizedDescription
                                        print(myError)
                                        self?.showAlert(title: "Ошибка",
                                                        text: myError,
                                                        buttonText: "Понятно")
                                    }
        }
    }
    
    
    @objc func signUpButtonPressed() {
        
    }
}

//MARK: - setupConstraints

extension LoginViewController {
    private func setupConstraints() {
        
        signInLogo.translatesAutoresizingMaskIntoConstraints = false
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        needAccountLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(signInLogo)
        view.addSubview(appleButton)
        view.addSubview(loginButton)
        view.addSubview(signUpButton)
        view.addSubview(emailLabel)
        view.addSubview(passwordLabel)
        view.addSubview(needAccountLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        
        NSLayoutConstraint.activate([
        signInLogo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
        signInLogo.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
        signInLogo.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
        
        appleButton.topAnchor.constraint(equalTo: signInLogo.bottomAnchor, constant: 28),
        appleButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
        appleButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
        appleButton.heightAnchor.constraint(equalTo: appleButton.widthAnchor, multiplier: 1.0/7.28),
        
        emailTextField.topAnchor.constraint(equalTo: appleButton.bottomAnchor, constant: 58),
        emailTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
        emailTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
        
        emailLabel.bottomAnchor.constraint(equalTo: emailTextField.topAnchor, constant: -5),
        emailLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
        emailLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
        
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 38),
        passwordTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
        passwordTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
        
        passwordLabel.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: -5),
        passwordLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
        passwordLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
        
        loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 25),
        loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
        loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
        loginButton.heightAnchor.constraint(equalTo: loginButton.widthAnchor, multiplier: 1.0/7.28),
        
        signUpButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
        signUpButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
        signUpButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
        signUpButton.heightAnchor.constraint(equalTo: signUpButton.widthAnchor, multiplier: 1.0/7.28),
        
        needAccountLabel.bottomAnchor.constraint(equalTo: signUpButton.topAnchor, constant: -5),
        needAccountLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
        
        ])
    }
}

//MARK: - showAlert
extension LoginViewController {
    
    private func showAlert(title: String, text: String, buttonText: String) {
        
        let alert = UIAlertController(title: title,
                                      text: text,
                                      buttonText: "",
                                      style: .alert)
        
        present(alert, animated: true, completion: nil)
    }
}
//MARK: - SwiftUI
struct LoginViewControllerProvider: PreviewProvider {
   
    static var previews: some View {
        ContenerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContenerView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: Context) -> LoginViewController {
            LoginViewController()
        }
        
        func updateUIViewController(_ uiViewController: LoginViewController, context: Context) {
            
        }
    }
}
