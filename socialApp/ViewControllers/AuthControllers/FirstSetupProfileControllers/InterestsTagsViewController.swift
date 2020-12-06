//
//  InterestsTagsViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 27.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class InterestsTagsViewController: UIViewController {

    private var userID: String
    private let tagsView = TagsSetupView(unselectTags: MDefaultInterests.getSortedInterests(),
                                         tagsHeader: "Выбранные интересы",
                                         viewHeader: MLabels.interestsTagsHeader.rawValue)

   
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tagsView.updateScrollView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tagsView.update()
    }
    
    private func setup() {
        
        view.backgroundColor = .myWhiteColor()
       
        navigationItem.backButtonTitle = "Назад"
        navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .save,
                                                         target: self,
                                                         action: #selector(saveButtonTapped)),
                                         animated: false)
        
        
    
    }
}


//MARK: obcj
extension InterestsTagsViewController {
    
    @objc private func saveButtonTapped() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        let id = userID
        let selecetedInterestsTags = tagsView.getSelectedTags()
        
        if Validators.shared.checkTagsIsFilled(tags: selecetedInterestsTags) {
            FirestoreService.shared.saveInterests(id: id,
                                                  interests: selecetedInterestsTags) {[weak self] result in
                switch result {
                
                case .success(_):
                    self?.navigationItem.rightBarButtonItem?.isEnabled = true
                    let nextViewController = DesiresTagsViewController(userID: id)
                    self?.navigationController?.pushViewController(nextViewController, animated: true)
                case .failure(let error):
                    self?.navigationItem.rightBarButtonItem?.isEnabled = true
                    PopUpService.shared.showInfo(text: "Ошибка: \(error)")
                }
            }
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
            PopUpService.shared.bottomPopUp(header: "Необходимо добавить минимум 3 интереса",
                                            text: "Ты можешь выбрать из списка, либо добавить свои",
                                            image: nil,
                                            okButtonText: "Добавить") {  }
        }

    }
}


//MARK: setupConstraints
extension InterestsTagsViewController {
    private func setupConstraints() {
        view.addSubview(tagsView)

        tagsView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tagsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tagsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tagsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tagsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
      
    }
}
