//
//  RequestViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 31.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI
import SDWebImage
import FirebaseAuth

class GetRequestViewController: UIViewController {
    
    let photo = UIImageView(image: nil, contentMode: .scaleAspectFill)
    let container = UIView()
    let nameLabel = UILabel(labelText: "Оленька", textFont: .boldSystemFont(ofSize: 22))
    let messageTextView = UILabel(labelText: "",
                                  multiline: true,
                                  textFont: .systemFont(ofSize: 16, weight: .bold),
                                  textColor: .label)
    let acceptButton = UIButton(newBackgroundColor: .myPurpleColor(), newBorderColor: .myPurpleColor(), title: "Принять", titleColor: .systemBackground)
    let denyButton = UIButton(newBackgroundColor: .myPinkColor(), newBorderColor: .myPinkColor(), title: "Отклонить", titleColor: .systemBackground)
    let buttonStackView = UIStackView()
    var chatRequestPeople: MChat!
    var currentUser: User!
    
    init(chatRequest: MChat, currentUser: User){
        chatRequestPeople = chatRequest
        self.currentUser = currentUser
        
        let imageURL = URL(string: chatRequest.friendUserImageString)
        photo.sd_setImage(with: imageURL, completed: nil)
        nameLabel.text = chatRequest.friendUserName
        messageTextView.text = chatRequest.lastMessage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setupConstraints()
        setupAction()
    }
    
    //MARK:  setupAction
    private func setupAction() {
        acceptButton.addTarget(self, action: #selector(touchAccept), for: .touchUpInside)
        denyButton.addTarget(self, action: #selector(touchDeny), for: .touchUpInside)
    }
    
    //MARK:  configure
    private func configure(){
        
        container.backgroundColor = .myBackgroundColor()
        container.layer.cornerRadius = 30
        
        buttonStackView.addArrangedSubview(denyButton)
        buttonStackView.addArrangedSubview(acceptButton)
        buttonStackView.alignment = .center
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 20
        buttonStackView.distribution = .fillEqually
    }
}

extension GetRequestViewController {
    
    @objc private func touchAccept() {
        FirestoreService.shared.changeToActive(chat: chatRequestPeople, forUser: currentUser)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func touchDeny() {
        
        FirestoreService.shared.deleteChatRequest(fromUser: chatRequestPeople, forUser: currentUser)
        dismiss(animated: true, completion: nil)
        
    }
}
//MARK:  setupConstraints
extension GetRequestViewController {
    
    private func setupConstraints() {
        
        photo.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        denyButton.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
      
        view.addSubview(photo)
        view.addSubview(container)
        container.addSubview(nameLabel)
        container.addSubview(messageTextView)
        container.addSubview(buttonStackView)
     
        
        NSLayoutConstraint.activate([
            
            //main constraints
            photo.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            photo.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            photo.topAnchor.constraint(equalTo: view.topAnchor),
            photo.bottomAnchor.constraint(equalTo: container.topAnchor, constant: 30),
            
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            container.heightAnchor.constraint(equalToConstant: 400),
            
            //container constraints
            
            nameLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 30),
            
            messageTextView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 30),
            messageTextView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 30),
            messageTextView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -30),
            
            buttonStackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 30),
            buttonStackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -30),
            buttonStackView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -30),
            buttonStackView.heightAnchor.constraint(equalToConstant: 50),
            
            acceptButton.heightAnchor.constraint(equalToConstant: 60),
            denyButton.heightAnchor.constraint(equalToConstant: 60)
            
            
        ])
    }
}


