//
//  MatchViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 05.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class MatchViewController: UIViewController {
    
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .myWhiteColor()
        return view
    }()
    let friendPhoto = UIImageView(image: #imageLiteral(resourceName: "advertLogo"), contentMode: .scaleAspectFill)
    let aboutFriend = UILabel(labelText: "У тебя пара с Пусечка", textFont: .avenirRegular(size: 16))
    let info = UILabel(labelText: "Веди себя хорошоо", textFont: .avenirRegular(size: 16), textColor: .myGrayColor())
    let okButton = UIButton(newBackgroundColor: .myWhiteColor(), title: "Позже", titleColor: .myGrayColor())
    let chatButton = UIButton(newBackgroundColor: .myWhiteColor(), title: "Начать общение", titleColor: .myLabelColor())
    weak var stackView: UIStackView?  {
        let stackView = UIStackView(arrangedSubviews: [okButton,chatButton])
        stackView.axis = .horizontal
        stackView.spacing = 30
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupConstraints()
    }
    
    
    private func setup() {
        view.backgroundColor = UIColor.myLabelColor().withAlphaComponent(0.5)
        friendPhoto.layer.cornerRadius = MDefaultLayer.bigCornerRadius.rawValue
        friendPhoto.clipsToBounds = true
        
    }
}

extension MatchViewController {
    private func setupConstraints() {
        guard let stackView = stackView else { return }
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        friendPhoto.translatesAutoresizingMaskIntoConstraints = false
        aboutFriend.translatesAutoresizingMaskIntoConstraints = false
        info.translatesAutoresizingMaskIntoConstraints = false
        okButton.translatesAutoresizingMaskIntoConstraints = false
        chatButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        containerView.addSubview(friendPhoto)
        containerView.addSubview(aboutFriend)
        containerView.addSubview(info)
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            
            containerView.topAnchor.constraint(equalTo: friendPhoto.topAnchor,constant: -20),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            friendPhoto.bottomAnchor.constraint(equalTo: aboutFriend.topAnchor, constant: -30),
            friendPhoto.heightAnchor.constraint(equalTo: friendPhoto.widthAnchor),
            friendPhoto.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            friendPhoto.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            aboutFriend.bottomAnchor.constraint(equalTo: info.topAnchor, constant: -5),
            aboutFriend.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            aboutFriend.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            info.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -30),
            info.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            info.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            stackView.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 50),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -50),
        ])
    }
}
