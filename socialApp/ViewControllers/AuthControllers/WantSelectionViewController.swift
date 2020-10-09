//
//  WantSelectionViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 15.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import FirebaseAuth

class WantSelectionViewController: UIViewController {
    
    let titleLabel = UILabel(labelText: "Кого предпочитаешь?",
                             textFont: .systemFont(ofSize: 22, weight: .bold))
    
    let manButton = UIButton(newBackgroundColor: .systemBackground,
                             borderWidth: 0,
                             title: "   ПАРНЕЙ",
                             titleColor: .label)
    let womanButton = UIButton(newBackgroundColor: .systemBackground,
                               borderWidth: 0,
                               title: "   ДЕВУШЕК",
                               titleColor: .label)
    
    let signUpButton = UIButton(newBackgroundColor: .label,
                                newBorderColor: .label,
                                title: "Продолжить",
                                titleColor: .systemBackground)
    let radioButton = RadioButton()

    var currentUser: User?
    
    init(currentUser: User?){
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupButton()
        setupConstraints()
    }
    
    private func setup() {
         view.backgroundColor = .systemBackground
        
        radioButton.buttonsArray = [manButton,womanButton]
        radioButton.defaultButton = womanButton
    }
    
    private func setupButton() {
        manButton.addTarget(self, action: #selector(touchManButton), for: .touchUpInside)
        womanButton.addTarget(self, action: #selector(touchWomanButton), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(touchSignUpButton), for: .touchUpInside)
    }
    
    //MARK: toMainTabBar
    private func toMainTabBar(user: User){
       let mainTabBarVC = MainTabBarController(currentUser: user)
        mainTabBarVC.modalPresentationStyle = .fullScreen
        present(mainTabBarVC, animated: true, completion: nil)
    }
    
    @objc private func touchManButton() {
        radioButton.buttonArrayUpdated(buttonSelected: manButton)
    }
    
    @objc private func touchWomanButton() {
        radioButton.buttonArrayUpdated(buttonSelected: womanButton)
    }
    
    //MARK: touchSignUpButton
    @objc private func touchSignUpButton() {
        let want = radioButton.selectedButton == manButton ? Want.man.rawValue : Want.woman.rawValue
        guard let user = currentUser else { fatalError("cant get user")}
        guard let uid = currentUser?.uid else { fatalError("cant get UID")}
        
        FirestoreService.shared.saveWant(id: uid, want: want, complition: {[weak self] result in
            switch result {
            case .success():
                FirestoreService.shared.saveDefaultImage(id: uid,
                                                         defaultImageString: DefaultImage.userAvatar.rawValue) { result in
                                                            switch result {
                                                                
                                                            case .success():
                                                                self?.toMainTabBar(user: user)
                                                            case .failure(let error):
                                                                fatalError(error.localizedDescription)
                                                            }
                }
            //failure to incorrect save Want
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        })
    }
    
    //MARK:  setupConstraints
    private func setupConstraints() {
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        manButton.translatesAutoresizingMaskIntoConstraints = false
        womanButton.translatesAutoresizingMaskIntoConstraints = false
        signUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(titleLabel)
        view.addSubview(manButton)
        view.addSubview(womanButton)
        view.addSubview(signUpButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            
            manButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            manButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -12),
            
            womanButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            womanButton.topAnchor.constraint(equalTo: manButton.bottomAnchor, constant: 25),
            
            signUpButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            signUpButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            signUpButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            signUpButton.heightAnchor.constraint(equalTo: signUpButton.widthAnchor, multiplier: 1.0/7.28)
        ])
    }
    
}

