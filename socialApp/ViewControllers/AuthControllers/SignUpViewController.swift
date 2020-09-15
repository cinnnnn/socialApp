//
//  SignUpViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 28.06.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    
    let signUpLogo = UIImageView(image: #imageLiteral(resourceName: "SignUpLogo"),
                                 contentMode: .scaleAspectFit)
    
    let loginLabel = UILabel(labelText: "Проверь test3@gmail.com почту",
                             textFont: .boldSystemFont(ofSize: 16),
                             opacity: 0)
    let emailInstructionLabel = UILabel(labelText: "Пройди по ссылке в письме для активации",
                                        multiline: true,
                                        textFont: .systemFont(ofSize: 12, weight: .thin),
                                        opacity:  0)
    let emailLabel = UILabel(labelText: "Твоя почта ",
                             textFont: .systemFont(ofSize: 16, weight: .light),
                             opacity: 1)
    let passwordLabel = UILabel(labelText: "Придумай к ней пароль",
                                textFont: .systemFont(ofSize: 16, weight: .regular),
                                opacity: 1)
    let confirmPasswordLabel = UILabel(labelText: "Повтори пароль",
                                       textFont: .systemFont(ofSize: 16, weight: .regular),
                                       opacity: 1)
    
    let passwordTextField = OneLineTextField(isSecureText: true,
                                             tag: 1,
                                             opacity: 1,
                                             isEnable: true)
    let confirmPasswordTextField = OneLineTextField(isSecureText: true,
                                                    tag: 2,
                                                    opacity: 1,
                                                    isEnable: true)
    
    let signUpButton = UIButton(newBackgroundColor: .label,
                                newBorderColor: .label,
                                title: "Продолжить",
                                titleColor: .systemBackground)
    
    let checkMailButton = UIButton(newBackgroundColor: .label,
                                   newBorderColor: .label,
                                   title: "Проверить активацию",
                                   titleColor: .systemBackground,
                                   isHidden: true)
    
    weak var delegate: AuthNavigationDelegate?
    var email:String?
    
    init(email: String?){
        self.email = email
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
extension SignUpViewController {
    
    private func setupVC() {
        view.backgroundColor = .systemBackground
        
        if let email = email {
            loginLabel.text = "Проверь \(email) почту, пройди по ссылке в письме для активации"
            emailLabel.text = "Твоя почта \(email)"
        }
        
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
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
        
        //check activation mail before next VC
        
        AuthService.shared.register(
            email: email,
            password: passwordTextField.text,
            confirmPassword: confirmPasswordTextField.text
        ) {[weak self] result in
            switch result {
            case .success(let user):
                guard let email = user.email else { fatalError("cant get email")}
                //if user create in auth, then create current user in cloud Firestore
                FirestoreService.shared.saveBaseProfile(id: user.uid,
                                                        email: email ) { result in
                                                            switch result {
                                                            case .success():
                                                                self?.dismiss(animated: true) {
                                                                    self?.delegate?.toGenderSelect(currentUser: user)
                                                                }
                                                            case .failure(let error):
                                                                fatalError(error.localizedDescription)
                                                            }
                }
                
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

//MARK: - UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField, nextField.isEnabled {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        return false
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
    
    private func showSexAlert(user: User) {
       let alert = UIAlertController(title: "Нужно знать твой пол",
                                     message: "Не ошибись, изменить пол будет невозможно",
                                     preferredStyle: .actionSheet)
        let saveAction = UIAlertAction(title: "Продолжить", style: .default) {[weak self] _ in
            self?.dismiss(animated: true,
                          completion: {
                            self?.delegate?.toMainTabBar(currentUser: user)
            })
        }
        alert.addAction(saveAction)
        
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
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        confirmPasswordLabel.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.addSubview(signUpLogo)
        view.addSubview(emailLabel)
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
            
            emailLabel.topAnchor.constraint(equalTo: signUpLogo.bottomAnchor, constant: 15),
            emailLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            emailLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            passwordTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 38),
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
            
            
            loginLabel.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 25),
            loginLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            loginLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            emailInstructionLabel.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 5),
            emailInstructionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            emailInstructionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            checkMailButton.topAnchor.constraint(equalTo: loginLabel.bottomAnchor, constant: 55),
            checkMailButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            checkMailButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            checkMailButton.heightAnchor.constraint(equalTo: checkMailButton.widthAnchor, multiplier: 1.0/7.28),
            
            
            signUpButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            signUpButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            signUpButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            signUpButton.heightAnchor.constraint(equalTo: signUpButton.widthAnchor, multiplier: 1.0/7.28)
        ])
    }
}


//MARK: - SwiftUI
struct SignUpViewControllerProvider: PreviewProvider {
    
    static var previews: some View {
        ContenerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContenerView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: Context) -> SignUpViewController {
            SignUpViewController(email: "Foo")
        }
        
        func updateUIViewController(_ uiViewController: SignUpViewController, context: Context) {
            
        }
    }
}
