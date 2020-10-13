//
//  UnterestsSelectionViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import FirebaseAuth

class InterestsSelectionViewController: UIViewController {
    
    var currentUser: User
    let headerLabel = UILabel(labelText: "Что ты ищешь?", textFont: .avenirBold(size: 24),linesCount: 0)
    let subHeaderLabel = UILabel(labelText: "Расскажи о своих интересах, что бы проще найти единомышленников",
                                 textFont: .avenirRegular(size: 16),
                                 textColor: .myGrayColor(),
                                 linesCount: 0)
    var aboutTextView = UITextView(text: "", isEditable: true)
    
    init(currentUser: User){
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupConstraints()
    }
    
    private func setup() {
        view.backgroundColor = .myWhiteColor()
        navigationController?.navigationBar.tintColor = .label
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.barTintColor = .myWhiteColor()
        
        navigationItem.backButtonTitle = "Назад"
        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .save,
                                                         target: self,
                                                         action: #selector(saveButtonTapped)),
                                         animated: false)
        
        aboutTextView.addDoneButton()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension InterestsSelectionViewController {
    @objc private func saveButtonTapped() {
        let nextViewController = EditPhotoViewController()
        navigationController?.pushViewController(nextViewController, animated: true)
    }
}

extension InterestsSelectionViewController {
    
    private func setupConstraints() {
        view.addSubview(headerLabel)
        view.addSubview(subHeaderLabel)
        view.addSubview(aboutTextView)
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        subHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            
            subHeaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10),
            subHeaderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            subHeaderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            
            aboutTextView.topAnchor.constraint(equalTo: subHeaderLabel.bottomAnchor, constant: 25),
            aboutTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            aboutTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
        ])
    }
}
