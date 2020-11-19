//
//  MatchViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 05.11.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftEntryKit

class MatchViewPopUp: UIView {
    
    let friendPhoto = UIImageView(image: #imageLiteral(resourceName: "advertLogo"), contentMode: .scaleAspectFill)
    let aboutFriend = UILabel(labelText: "", textFont: .avenirRegular(size: 16))
    let info = UILabel(labelText: "Чувства взаимны. Будь смелей и веди себя хорошо", textFont: .avenirRegular(size: 16), textColor: .myGrayColor())
    let dismisButton = UIButton(newBackgroundColor: .myWhiteColor(), title: "Позже", titleColor: .myGrayColor())
    let chatButton = UIButton(newBackgroundColor: .myWhiteColor(), title: "Начать общение", titleColor: .myLabelColor())
    weak var stackView: UIStackView?  {
        let stackView = UIStackView(arrangedSubviews: [dismisButton,chatButton])
        stackView.axis = .horizontal
        stackView.spacing = 30
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    let chat: MChat
    let currentPeople: MPeople
    var okAction: () -> ()
    
    init(currentPeople: MPeople, chat: MChat, okAction: @escaping ()->()) {
        self.currentPeople = currentPeople
        self.chat = chat
        self.okAction = okAction
        super.init(frame: UIScreen.main.bounds)
        setup()
        setupConstraints()
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setup() {
        backgroundColor = .myWhiteColor()
        layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        layer.cornerRadius = MDefaultLayer.bigCornerRadius.rawValue
        clipsToBounds = true
        friendPhoto.layer.cornerRadius = MDefaultLayer.bigCornerRadius.rawValue
        friendPhoto.clipsToBounds = true
        
        if let imageURL = URL(string: chat.friendUserImageString) {
            friendPhoto.sd_setImage(with: imageURL, completed: nil)
        }
        aboutFriend.text = "У тебя связь с \(chat.friendUserName)"
    }
    
    private func setupButton() {
        dismisButton.addTarget(self, action: #selector(dismisTapped), for: .touchUpInside)
        chatButton.addTarget(self, action: #selector(chatTapped), for: .touchUpInside)
    }
}

extension MatchViewPopUp {
    @objc func dismisTapped() {
        SwiftEntryKit.dismiss()
    }
    
    @objc func chatTapped() {
        okAction()
        SwiftEntryKit.dismiss()
    }
}

extension MatchViewPopUp {
    private func setupConstraints() {
        guard let stackView = stackView else { return }
        
        friendPhoto.translatesAutoresizingMaskIntoConstraints = false
        aboutFriend.translatesAutoresizingMaskIntoConstraints = false
        info.translatesAutoresizingMaskIntoConstraints = false
        dismisButton.translatesAutoresizingMaskIntoConstraints = false
        chatButton.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(friendPhoto)
        addSubview(friendPhoto)
        addSubview(aboutFriend)
        addSubview(info)
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            
            topAnchor.constraint(equalTo: friendPhoto.topAnchor,constant: -20),
            bottomAnchor.constraint(equalTo: bottomAnchor),
            leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: trailingAnchor),
            
            friendPhoto.bottomAnchor.constraint(equalTo: aboutFriend.topAnchor, constant: -30),
            friendPhoto.heightAnchor.constraint(equalTo: friendPhoto.widthAnchor),
            friendPhoto.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            friendPhoto.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            aboutFriend.bottomAnchor.constraint(equalTo: info.topAnchor, constant: -5),
            aboutFriend.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            aboutFriend.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            info.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -30),
            info.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            info.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 50),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -50),
        ])
    }
}
