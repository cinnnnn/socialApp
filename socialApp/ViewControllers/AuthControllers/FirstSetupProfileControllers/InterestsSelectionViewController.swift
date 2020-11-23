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
    
    var userID: String
    let headerLabel = UILabel(labelText: MLabels.interestSelectionHeader.rawValue, textFont: .avenirBold(size: 24),linesCount: 0)
    let subHeaderLabel = UILabel(labelText: MLabels.interestSelectionSubHeader.rawValue,
                                 textFont: .avenirRegular(size: 16),
                                 textColor: .myGrayColor(),
                                 linesCount: 0)
    var aboutTextView = UITextView(text: "", isEditable: true)
    
    init(userID: String){
        self.userID = userID
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
        
        let id = userID
        FirestoreService.shared.saveAdvert(id: id, advert: aboutTextView.text ?? "") {[weak self] result in
            switch result {
            
            case .success():
                let nextViewController = EditPhotoViewController(userID: id, isFirstSetup: true)
                self?.navigationController?.pushViewController(nextViewController, animated: true)
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
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
