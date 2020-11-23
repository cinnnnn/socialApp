//
//  DateOfBirthViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//


import UIKit
import FirebaseAuth

class DateOfBirthViewController: UIViewController {
    
    var userID: String
    
    let headerLabel = UILabel(labelText: MLabels.dateOfBirthHeader.rawValue, textFont: .avenirBold(size: 24),linesCount: 0)
    let subHeaderLabel = UILabel(labelText: MLabels.dateOfBirthSubHeader.rawValue, textFont: .avenirRegular(size: 16), textColor: .myGrayColor(), linesCount: 0)
    let dateLabel = UILabel(labelText: "День рождения", textFont: .avenirRegular(size: 16), textColor: .myGrayColor())
    let datePicker = UIDatePicker(datePickerMode: .date)
    weak var navigationDelegate: NavigationDelegate?
    
    init(userID: String, navigationDelegate: NavigationDelegate? ){
        self.navigationDelegate = navigationDelegate
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
        navigationController?.navigationBar.isHidden = false
//        navigationController?.navigationBar.tintColor = .label
//        navigationController?.navigationBar.shadowImage = nil
//        navigationController?.navigationBar.barTintColor = .myWhiteColor()
        
        navigationItem.backButtonTitle = "Назад"
        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .save,
                                                         target: self,
                                                         action: #selector(saveButtonTapped)),
                                         animated: false)
    }
}

extension  DateOfBirthViewController {
    
    @objc private func saveButtonTapped() {
        
        let id = userID
        FirestoreService.shared.saveFirstSetupDateOfBirth(id: id, dateOfBirth: datePicker.date) {[weak self] result in
            switch result {
            
            case .success():
                let nextViewController = GenderSelectionViewController(userID: id, navigationDelegate: self?.navigationDelegate)
                self?.navigationController?.pushViewController(nextViewController, animated: true)
            case .failure(let error):
                fatalError(error.localizedDescription)
            }
        }
    }
}

extension DateOfBirthViewController {
    
    private func setupConstraints() {
        view.addSubview(headerLabel)
        view.addSubview(subHeaderLabel)
        view.addSubview(dateLabel)
        view.addSubview(datePicker)
        
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        subHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            headerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25),
            headerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            
            subHeaderLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 10),
            subHeaderLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            subHeaderLabel.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor),
            
            dateLabel.topAnchor.constraint(equalTo: subHeaderLabel.bottomAnchor, constant: 45),
            dateLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor),
            
            datePicker.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            datePicker.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor),
        ])
    }
}
