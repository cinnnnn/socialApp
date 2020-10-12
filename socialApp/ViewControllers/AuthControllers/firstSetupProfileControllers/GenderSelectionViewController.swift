//
//  GenderSelectionTableViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 11.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import FirebaseAuth

class GenderSelectionViewController: UIViewController {

    var currentUser: User?
    
    let headerLabel = UILabel(labelText: "Немного больше о тебе", textFont: .avenirBold(size: 24))
    let genderSelectionButton = OneLineButton(header: "Гендер", info: "Man")
    let sexualitySelectionButton = OneLineButton(header: "Сексуальность", info: "Straight")
    let nameLabel = UILabel(labelText: "Вымышленное имя", textFont: .avenirRegular(size: 16), textColor: .myGrayColor())
    let nameTextField = OneLineTextField(isSecureText: false, tag: 1)

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
        
        genderSelectionButton.addTarget(self, action: #selector(genderSelectTapped), for: .touchUpInside)
        sexualitySelectionButton.addTarget(self, action: #selector(sexualitySelectTapped), for: .touchUpInside)
    }
    
    @objc private func saveButtonTapped() {
        let nextViewController = SexualitySelectionViewController()
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @objc private func genderSelectTapped() {
        let vc = SelectionViewController(elements: MGender.modelStringAllCases,
                                         description: MGender.description,
                                         selectedValue: genderSelectionButton.infoLabel.text ?? "",
                                         complition: {[weak self] selected in
                                            self?.genderSelectionButton.infoLabel.text = selected
                                         })
        vc.modalPresentationStyle = .overCurrentContext
        
        present(vc, animated: true, completion: nil)
        
    }


    @objc private func sexualitySelectTapped() {
        let vc = SelectionViewController(elements: MSexuality.modelStringAllCases,
                                         description: MSexuality.description,
                                         selectedValue: sexualitySelectionButton.infoLabel.text ?? "",
                                         complition: { [weak self] selected in
                                            self?.sexualitySelectionButton.infoLabel.text = selected
                                         })
        vc.modalPresentationStyle = .overCurrentContext
        
        present(vc, animated: true, completion: nil)
    }
}

extension GenderSelectionViewController {
    private func setupConstraints() {
        view.addSubview(headerLabel)
        view.addSubview(nameLabel)
        view.addSubview(nameTextField)
        view.addSubview(genderSelectionButton)
        view.addSubview(sexualitySelectionButton)
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        genderSelectionButton.translatesAutoresizingMaskIntoConstraints = false
        sexualitySelectionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            
            nameLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 25),
            nameLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            nameTextField.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor),
            
            genderSelectionButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 25),
            genderSelectionButton.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            genderSelectionButton.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor),
            genderSelectionButton.heightAnchor.constraint(equalToConstant: 70),
            
            sexualitySelectionButton.topAnchor.constraint(equalTo: genderSelectionButton.bottomAnchor, constant: 25),
            sexualitySelectionButton.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            sexualitySelectionButton.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor),
            sexualitySelectionButton.heightAnchor.constraint(equalToConstant: 70),
        ])
    }
}
