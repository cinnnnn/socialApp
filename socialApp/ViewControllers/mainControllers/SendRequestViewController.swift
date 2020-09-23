//
//  UserViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 29.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI
import SDWebImage


class SendRequestViewController: UIViewController {
    
    let photo = UIImageView(image: #imageLiteral(resourceName: "advertLogo"), contentMode: .scaleAspectFill)
    let container = UIView()
    let nameLabel = UILabel(labelText: "", textFont: .boldSystemFont(ofSize: 22))
    let messageTextView = UILabel(labelText: "",
                                  multiline: true,
                                  textFont: .systemFont(ofSize: 16, weight: .bold),
                                  textColor: .label)
    let unswerTextField = OneLineTextField(isSecureText: false,
                                           tag: 1,
                                           withButton: true,
                                           buttonText: "Отправить",
                                           placeHoledText: "Сообщение")
    let requestToPeople: MPeople!
    let currentPeople: MPeople!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        setupConstraints()
        setupAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setData()
    }
    
    init(requestForPeople: MPeople, from: MPeople) {
        self.requestToPeople = requestForPeople
        self.currentPeople = from
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:  setData
    private func setData() {
        
        let imageURL = URL(string: requestToPeople.userImage)
        photo.sd_setImage(with: imageURL, completed: nil)
        
        nameLabel.text = requestToPeople.userName
        messageTextView.text = requestToPeople.advert
        
    }
    //MARK:  setupAction
    private func setupAction() {
        
        if let sendButton = unswerTextField.rightView as? UIButton {
            sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        }
    }
    
    @objc func sendMessage() {
        let text = unswerTextField.text ?? ""
        unswerTextField.rightView?.isHidden = true
        FirestoreService.shared.sendChatRequest(fromUser: currentPeople,
                                                forFrend: requestToPeople,
                                                text: text) {[weak self] result in
            switch result {
            
            case .success(_):
                self?.dismiss(animated: true, completion: nil)
            case .failure(let error):
                self?.unswerTextField.rightView?.isHidden = false
                fatalError(error.localizedDescription)
            }
        }
    }
    
    //MARK: - configure()
    private func configure(){
        
        container.backgroundColor = .myBackgroundColor()
        container.layer.cornerRadius = 30
    }
}

//MARK: touchBegan
extension SendRequestViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

//MARK setupConstraints
extension SendRequestViewController {
    private func setupConstraints() {
        
        photo.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        unswerTextField.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.addSubview(photo)
        view.addSubview(container)
        container.addSubview(nameLabel)
        container.addSubview(messageTextView)
        container.addSubview(unswerTextField)
        
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
            
            unswerTextField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 30),
            unswerTextField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -30),
            unswerTextField.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -60),
            unswerTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
