//
//  SetProfileViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 04.07.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI
import FirebaseAuth

class SetProfileViewController: UIViewController {
    
    let profileImage = ProfileImageView()
    let nameLabel = UILabel(labelText: "Сегодня называй меня:")
    let aboutLabel = UILabel(labelText: "Мои желания на сегодоня:")
    let sexLabel = UILabel(labelText: "Мой пол:")
    let wantLabel = UILabel(labelText: "Ищу:")
    let nameTextField = OneLineTextField(isSecureText: false)
    let aboutTextField = OneLineTextField(isSecureText: false)
    let sexSegmentedControl = UISegmentedControl(first: "Парень",
                                                 second: "Девушка",
                                                 selectedIndex: 0)
    let wantSegmentedControl = UISegmentedControl(first: "Парня",
                                                  second: "Девушку",
                                                  selectedIndex: 1)
    let goButton = UIButton(newBackgroundColor: .label,
                            newBorderColor: .label,
                            title: "Начнем!",
                            titleColor: .systemBackground)
    
    var delegate: AuthNavigationDelegate?
    
    private var currentUser: User
    
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupConstraints()
        setupButtonAction()

        view.backgroundColor = .systemBackground
    }
}

//MARK: - setupButtonAction
extension SetProfileViewController {
    
    private func setupButtonAction() {
        
        goButton.addTarget(self, action: #selector(goButtonPressed), for: .touchUpInside)
        
    }
}

//MARK: - objc action
extension SetProfileViewController {
    
    @objc func goButtonPressed() {
        
        guard let sex = sexSegmentedControl.titleForSegment(at: sexSegmentedControl.selectedSegmentIndex) else { return }
        guard let search = wantSegmentedControl.titleForSegment(at: wantSegmentedControl.selectedSegmentIndex) else { return }
        
        guard let email = currentUser.email else { return }
         
        FirestoreService.shared.saveProfile(id: currentUser.uid,
                                            email: email,
                                            username: nameTextField.text,
                                            avatarImage:"unloaded",
                                            advert: aboutTextField.text,
                                            search: search,
                                            sex: sex ) {[weak self] result in
                                                
                                                switch result {
                                                    
                                                case .success(_):
                                                    self?.dismiss(animated: true) {
                                                        self?.delegate?.toMainTabBar()
                                                    }
                                                case .failure(let error):
                                                    print(error.localizedDescription)
                                                }
        }
    }
}

//MARK: - setupConstraints
extension SetProfileViewController {
    
    private func setupConstraints() {
        
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutLabel.translatesAutoresizingMaskIntoConstraints = false
        sexLabel.translatesAutoresizingMaskIntoConstraints = false
        wantLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        aboutTextField.translatesAutoresizingMaskIntoConstraints = false
        sexSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        wantSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        goButton.translatesAutoresizingMaskIntoConstraints = false
    
        view.addSubview(profileImage)
        view.addSubview(nameLabel)
        view.addSubview(aboutLabel)
        view.addSubview(sexLabel)
        view.addSubview(wantLabel)
        view.addSubview(nameTextField)
        view.addSubview(aboutTextField)
        view.addSubview(sexSegmentedControl)
        view.addSubview(wantSegmentedControl)
        view.addSubview(goButton)
      
        NSLayoutConstraint.activate([
        
            profileImage.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: (view.frame.width / 2) / 7.5),
            profileImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            profileImage.widthAnchor.constraint(equalToConstant: self.view.frame.width / 2),
            profileImage.heightAnchor.constraint(equalTo: profileImage.widthAnchor, multiplier: 1/1),
            
            nameTextField.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 28),
            nameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            nameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            nameLabel.bottomAnchor.constraint(equalTo: nameTextField.topAnchor, constant: -5),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            aboutTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 38),
            aboutTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            aboutTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            aboutLabel.bottomAnchor.constraint(equalTo: aboutTextField.topAnchor, constant: -5),
            aboutLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            aboutLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            sexSegmentedControl.topAnchor.constraint(equalTo: aboutTextField.bottomAnchor, constant: 38),
            sexSegmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            sexSegmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            sexLabel.bottomAnchor.constraint(equalTo: sexSegmentedControl.topAnchor, constant: -5),
            sexLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            sexLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            wantSegmentedControl.topAnchor.constraint(equalTo: sexSegmentedControl.bottomAnchor, constant: 38),
            wantSegmentedControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            wantSegmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            wantLabel.bottomAnchor.constraint(equalTo: wantSegmentedControl.topAnchor, constant: -5),
            wantLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            wantLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            
            goButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -25),
            goButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25),
            goButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -25),
            goButton.heightAnchor.constraint(equalTo: goButton.widthAnchor, multiplier: 1.0/7.28),
        ])
    }
    
}

//MARK: - SwiftUI
struct SetupProfileViewControllerProvider: PreviewProvider {
   
    static var previews: some View {
        ContenerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContenerView: UIViewControllerRepresentable {
        
        func makeUIViewController(context: Context) -> SetProfileViewController {
            SetProfileViewController(currentUser: Auth.auth().currentUser!)
        }
        
        func updateUIViewController(_ uiViewController: SetProfileViewController, context: Context) {
            
        }
    }
}
