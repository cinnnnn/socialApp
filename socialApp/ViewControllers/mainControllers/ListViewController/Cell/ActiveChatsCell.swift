//
//  ActiveChatsCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI
import SDWebImage

class ActiveChatsCell: UICollectionViewCell, SelfConfiguringCell {
    static var reuseID: String = "ActiveChatCell"
    
    let frendImage = UIImageView(image: #imageLiteral(resourceName: "advertLogo"), contentMode: .scaleAspectFill)
    let frendName = UILabel(labelText: "", textFont: .boldSystemFont(ofSize: 11), textColor: .myGrayColor())
    let lastMessage = UILabel(labelText: "", textFont: .systemFont(ofSize: 14), textColor: .myGrayColor())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupConstraints()
    }
    
      //MARK: - setup
    private func setup() {
        
        layer.cornerRadius = 4
        backgroundColor = .systemBackground
        
        clipsToBounds = true
        frendImage.clipsToBounds = true
    }
    //MARK: - configure
    func configure(with value: MChat) {
        
        let imageURL = URL(string: value.friendUserImageString)
        frendImage.sd_setImage(with: imageURL, completed: nil)
        frendName.text = value.friendUserName
        lastMessage.text = value.lastMessage
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        frendImage.layer.cornerRadius = frendImage.frame.height / 2
    }
}

//MARK: -  setupConstraints
extension ActiveChatsCell {
    private func setupConstraints() {
        
        frendImage.translatesAutoresizingMaskIntoConstraints = false
        frendName.translatesAutoresizingMaskIntoConstraints = false
        lastMessage.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(frendImage)
        addSubview(frendName)
        addSubview(lastMessage)
        
        NSLayoutConstraint.activate([
            frendImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            frendImage.topAnchor.constraint(equalTo: topAnchor),
            frendImage.bottomAnchor.constraint(equalTo: bottomAnchor),
            frendImage.widthAnchor.constraint(equalTo: frendImage.heightAnchor),
            
            frendName.leadingAnchor.constraint(equalTo: frendImage.trailingAnchor, constant: 10),
            frendName.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            
            lastMessage.leadingAnchor.constraint(equalTo: frendName.leadingAnchor),
            lastMessage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
            
        ])
    }
    
}




