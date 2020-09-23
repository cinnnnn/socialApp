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
    
    let loginButton = UIButton(newBackgroundColor: .label,
                               newBorderColor: .label,
                               title: "Далее",
                               titleColor: .systemBackground)
    
    let emailTextField = OneLineTextField(isSecureText: false,
                                          tag: 1)
    let passwordTextField = OneLineTextField(isSecureText: true,
                                             tag: 2,
                                             opacity: 0,
                                             isEnable: false)
    
    let emailLabel = UILabel(labelText: "Напиши свою почту")
    let correctEmailLabel = UILabel(labelText: "Неправильно введена почта",
                                    textColor: .red,
                                    opacity: 0)
    let passwordLabel = UILabel(labelText: "Пароль",
                                opacity: 0)
    
    weak var delegate: AuthNavigationDelegate?
    
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
        loginButton.isEnabled = false
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
}
//MARK: - setupButtonAction
extension LoginViewController {
    
    private func setupButtonAction() {
        
        loginButton.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        emailTextField.addTarget(self, action: #selector(emailEnterComplite), for: .editingDidEnd)
    }
}

extension LoginViewController {
    //MARK:  emailEnterComplite
    @objc func emailEnterComplite() {
        
        guard let email = emailTextField.text, email != "" else { return }
        
        guard Validators.shared.isEmail(email: email) else {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.loginButton.isEnabled = false
                self?.correctEmailLabel.layer.opacity = 1
                self?.emailTextField.becomeFirstResponder()
                self?.passwordTextField.text = ""
                self?.passwordTextField.layer.opacity = 0
                self?.passwordLabel.layer.opacity = 0
            }
            return
        }
        
        AuthService.shared.isEmailAlreadyRegister(email: email) {[weak self] result in
            switch result {
                
            case .success(let isRegister):
                if isRegister {
                    self?.passwordTextField.isEnabled = true
                    UIView.animate(withDuration: 0.3) {
                        self?.correctEmailLabel.layer.opacity = 0
                        self?.passwordTextField.layer.opacity = 1
                        self?.passwordLabel.layer.opacity = 1
                        self?.resignFirstResponder()
                        self?.loginButton.isEnabled = true
                    }
                } else {
                    self?.passwordTextField.isEnabled = false
                    UIView.animate(withDuration: 0.3) {
                        self?.correctEmailLabel.layer.opacity = 0
                        self?.passwordTextField.text = ""
                        self?.passwordTextField.layer.opacity = 0
                        self?.passwordLabel.layer.opacity = 0
                    }
                    self?.loginButton.isEnabled = true
                }
            case .failure(_):
                fatalError("Cant fetch Email registration status")
            }
        }
    }
    
    //MARK: - loginButtonPressed
    @objc func loginButtonPressed() {
        
        switch passwordTextField.isEnabled {
        case true:
            AuthService.shared.signIn(email: emailTextField.text,
                                      password: passwordTextField.text) {[weak self] result in
                                        switch result {
                                        case .success( let user):
                                            //if correct login user, than close LoginVC and check setProfile info
                                            FirestoreService.shared.getUserData(userID: user.uid) { result in
                                                switch result {
                                                
                                                case .success(let mPeople):
                                                    self?.dismiss(animated: true) {
                                                        if mPeople.sex == "" {
                                                            self?.delegate?.toGenderSelect(currentUser: user)
                                                        } else if mPeople.search == "" {
                                                            self?.delegate?.toWantSelect(currentUser: user)
                                                        } else {
                                                            self?.delegate?.toMainTabBar(currentUser: user)
                                                        }
                                                    }
                                                    //error of getUserData
                                                case .failure(let error):
                                                    fatalError(error.localizedDescription)
                                                }
                                            }
                                        //error of logIn
                                        case .failure(let eror):
                                            let myError = eror.localizedDescription
                                            print(myError)
                                            self?.showAlert(title: "Ошибка",
                                                            text: myError,
                                                            buttonText: "Понятно")
                                        }
            }
            //if passwordTextField is disable go to RegisterVC
        default:
            dismiss(animated: true) {
                self.delegate?.toRegister(email: self.emailTextField.text)
            }
        }
    }
}

//MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextField {
            textField.selectAll(nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            if Validators.shared.isEmail(email: emailTextField.text ?? "") {
                emailEnterComplite()
            }
        }
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField, nextField.isEnabled {
            
            if Validators.shared.isEmail(email: emailTextField.text ?? "") {
                nextField.becomeFirstResponder()
            } else {
                textField.becomeFirstResponder()
                textField.selectAll(nil)
                emailEnterComplite()
                return false
            }
            
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        return false
    }
}

//MARK:  showAlert
extension LoginViewController {
    
    private func showAlert(title: String, text: String, buttonText: String) {
        
        let alert = UIAlertController(title: title,
                                      text: text,
                                      buttonText: "",
                                      style: .alert)
        
        present(alert, animated: true, completion: nil)
    }
}

//MARK touchBegan
extension LoginViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }
}

//MARK: - setupConstraints

extension LoginViewController {
    private func setupConstraints() {
        
        signInLogo.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        correctEmailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(signInLogo)
        view.addSubview(loginButton)
        view.addSubview(correctEmailLabel)
        view.addSubview(emailLabel)
        view.addSubview(passwordLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        
        NSLayoutConstraint.activate([
            signInLogo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            signInLogo.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            signInLogo.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            
            emailTextField.topAnchor.constraint(equalTo: signInLogo.bottomAnchor, constant: 58),
            emailTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            emailTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            emailLabel.bottomAnchor.constraint(equalTo: emailTextField.topAnchor, constant: -5),
            emailLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            emailLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            correctEmailLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 5),
            correctEmailLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            correctEmailLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            
            passwordTextField.topAnchor.constraint(equalTo: correctEmailLabel.bottomAnchor, constant: 38),
            passwordTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            passwordTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            passwordLabel.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: -5),
            passwordLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            passwordLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            loginButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            loginButton.heightAnchor.constraint(equalTo: loginButton.widthAnchor, multiplier: 1.0/7.28),
            
        ])
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
