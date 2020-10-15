//
//  LoginViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 02.07.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI
import FirebaseAuth

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
    
    weak var navigationDelegate: NavigationDelegate?
    
    init(navigationDelegate: NavigationDelegate?){
        self.navigationDelegate = navigationDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        navigationItem.backButtonTitle = "Указать другой email"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .myWhiteColor()
        navigationController?.navigationBar.tintColor = .label
        
        loginButton.isEnabled = false
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
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
        //check current email in Firebase auth, than show password textField
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
                self?.showAlert(title: "Проблемы с подключением", text: "Повтори чуть позже", buttonText: "OK")
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
                    
                    FirestoreService.shared.getUserData(userID: user.email! ) { result in
                        switch result {
                        
                        case .success(let mPeople):
                            if mPeople.gender == "" || mPeople.lookingFor == "" {
                                self?.navigationDelegate?.toCompliteRegistration(user: user)
                            } else {
                                let mainVC = MainTabBarController(currentUser: user)
                                mainVC.modalPresentationStyle = .fullScreen
                                self?.present(mainVC, animated: true, completion: nil)
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
                    self?.showAlert(title: "Ошибка входа",
                                    text: "Некорректная комбинация email/пароль",
                                    buttonText: "Попробую еще")
                }
            }
        //if passwordTextField is disable go to RegisterVC
        default:
            guard let delegate = navigationDelegate else { fatalError("Can't get navigationDelegate")}
            let registerEmailVC = RegisterEmailViewController(email: emailTextField.text, navigationDelegate: delegate)
            navigationController?.pushViewController(registerEmailVC, animated: true)
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
                                      buttonText: buttonText,
                                      style: .alert)
        
        alert.setMyLightStyle()
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
        
        view.addSubview(signInLogo)
        view.addSubview(loginButton)
        view.addSubview(correctEmailLabel)
        view.addSubview(emailLabel)
        view.addSubview(passwordLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        
        signInLogo.anchor(leading: view.leadingAnchor,
                          trailing: view.trailingAnchor,
                          top: view.safeAreaLayoutGuide.topAnchor,
                          bottom: nil,
                          padding: .init(top: 80, left: 25, bottom: 0, right: 25))
        
        emailTextField.anchor(leading: view.leadingAnchor,
                              trailing: view.trailingAnchor,
                              top: signInLogo.bottomAnchor,
                              bottom: nil,
                              padding: .init(top: 60, left: 25, bottom: 0, right: 25))
        
        emailLabel.anchor(leading: view.leadingAnchor,
                          trailing: view.trailingAnchor,
                          top: emailTextField.topAnchor,
                          bottom: nil,
                          padding: .init(top: -15, left: 25, bottom: 0, right: 25))
        
        correctEmailLabel.anchor(leading: view.leadingAnchor,
                                 trailing: view.trailingAnchor,
                                 top: emailTextField.bottomAnchor,
                                 bottom: nil,
                                 padding: .init(top: 5, left: 25, bottom: 0, right: 25))
        
        passwordTextField.anchor(leading: view.leadingAnchor,
                                 trailing: view.trailingAnchor,
                                 top: correctEmailLabel.topAnchor,
                                 bottom: nil,
                                 padding: .init(top: 40, left: 25, bottom: 0, right: 25))
        
        passwordLabel.anchor(leading: view.leadingAnchor,
                             trailing: view.trailingAnchor,
                             top: passwordTextField.topAnchor,
                             bottom: nil,
                             padding: .init(top: -15, left: 25, bottom: 0, right: 25))
        
        loginButton.anchor(leading: view.leadingAnchor,
                           trailing: view.trailingAnchor,
                           top: nil,
                           bottom: view.safeAreaLayoutGuide.bottomAnchor,
                           height: loginButton.widthAnchor,
                           multiplier: .init(width: 0, height: 1.0/7.28),
                           padding: .init(top: 0, left: 25, bottom: 25, right: 25))
    }
}
