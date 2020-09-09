//
//  SignUpViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 28.06.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI

class SignUpViewController: UIViewController {
    
    
    let signUpLogo = UIImageView(image: #imageLiteral(resourceName: "SignUpLogo"),
                                 contentMode: .scaleAspectFit)
    
    let loginLabel = UILabel(labelText: "Проверь test3@gmail.com почту",
                             textFont: .boldSystemFont(ofSize: 18))
    let emailInstructionLabel = UILabel(labelText: "Пройди по ссылке в письме для активации",
                                        multiline: true,
                                        textFont: .systemFont(ofSize: 12, weight: .thin))
    let passwordLabel = UILabel(labelText: "Придумай пароль",
                                opacity: 0)
    let confirmPasswordLabel = UILabel(labelText: "Повтори пароль",
                                       opacity: 0)
    
    let passwordTextField = OneLineTextField(isSecureText: true,
                                             tag: 1,
                                             opacity: 0,
                                             isEnable: true)
    let confirmPasswordTextField = OneLineTextField(isSecureText: true,
                                                    tag: 2,
                                                    opacity: 0,
                                                    isEnable: true)
    
    let signUpButton = UIButton(newBackgroundColor: .label,
                                newBorderColor: .label,
                                title: "Зарегистрироваться",
                                titleColor: .systemBackground,
                                isHidden: true,
                                opacity: 0)
    let checkMailButton = UIButton(newBackgroundColor: .label,
                             newBorderColor: .label,
                             title: "Проверить активацию",
                             titleColor: .systemBackground)
    
    weak var delegate: AuthNavigationDelegate?
    var email:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupVC()
        setupConstraints()
        setupButtonAction()
    }    
}

//MARK: - setupVC
extension SignUpViewController {
    
    private func setupVC() {
        view.backgroundColor = .systemBackground
        
        if let email = email {
            
            loginLabel.text = "Проверь \(email) почту, пройди по ссылке в письме для активации"
        }
        
    }
}

//MARK: - setupButtonAction
extension SignUpViewController {
    
    private func setupButtonAction() {
        
        signUpButton.addTarget(self, action: #selector(signUpButtonPressed), for: .touchUpInside)
    }
}

//MARK: - objc action
extension SignUpViewController {
    
    @objc func signUpButtonPressed() {
        
        signUpButton.isEnabled = false
        AuthService.shared.register(email: email,
                                    password: passwordTextField.text,
                                    confirmPassword: confirmPasswordTextField.text) {[weak self] result in
                                        
                                        switch result {
                                            
                                        case .success(let user):
                                            
                                            self?.dismiss(animated: true,
                                                          completion: {
                                                            self?.delegate?.toSetProfile(user: user)
                                            })
                                            
                                        case .failure(let error):
                                            let myError = error.localizedDescription
                                            self?.showAlert(title: "Ошибка",
                                                            text: myError,
                                                            buttonText: "Понятно")
                                            self?.signUpButton.isEnabled = true
                                            
                                        }
        }
        
    }
    
    @objc func loginButtonPressed() {
        dismiss(animated: true) {
            self.delegate?.toLogin()
        }
    }
}

//MARK: - setupConstraints
extension SignUpViewController {
    private func setupConstraints() {
        
        signUpLogo.translatesAutoresizingMaskIntoConstraints = false
        emailInstructionLabel.translatesAutoresizingMaskIntoConstraints = false
        checkMailButton.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordLabel.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.addSubview(signUpLogo)
        view.addSubview(emailInstructionLabel)
        view.addSubview(checkMailButton)
        view.addSubview(passwordTextField)
        view.addSubview(confirmPasswordTextField)
        view.addSubview(loginLabel)
        view.addSubview(passwordLabel)
        view.addSubview(confirmPasswordLabel)
        view.addSubview(signUpButton)
        
        NSLayoutConstraint.activate([
            signUpLogo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            signUpLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            loginLabel.topAnchor.constraint(equalTo: signUpLogo.bottomAnchor, constant: 5),
            loginLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            loginLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            emailInstructionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 5),
            emailInstructionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            emailInstructionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            checkMailButton.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 55),
            checkMailButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            checkMailButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            checkMailButton.heightAnchor.constraint(equalTo: checkMailButton.widthAnchor, multiplier: 1.0/7.28),
            
            passwordTextField.topAnchor.constraint(equalTo: checkMailButton.bottomAnchor, constant: 68),
            passwordTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            passwordTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            passwordLabel.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: -5),
            passwordLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            passwordLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 68),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            confirmPasswordLabel.bottomAnchor.constraint(equalTo: confirmPasswordTextField.topAnchor, constant: -5),
            confirmPasswordLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            confirmPasswordLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            signUpButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            signUpButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            signUpButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            signUpButton.heightAnchor.constraint(equalTo: signUpButton.widthAnchor, multiplier: 1.0/7.28)
        ])
    }
}

//MARK: - showAlert
extension SignUpViewController {
    
    private func showAlert(title: String,
                           text: String,
                           buttonText: String,
                           complition: @escaping ()-> Void = { }) {
        
        let alert = UIAlertController(title: title,
                                      text: text,
                                      buttonText: buttonText,
                                      style: .alert,
                                      buttonHandler: complition)
        
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - SwiftUI
struct SignUpViewControllerProvider: PreviewProvider {
    
    static var previews: some View {
        ContenerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContenerView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: Context) -> SignUpViewController {
            SignUpViewController()
        }
        
        func updateUIViewController(_ uiViewController: SignUpViewController, context: Context) {
            
        }
    }
}
