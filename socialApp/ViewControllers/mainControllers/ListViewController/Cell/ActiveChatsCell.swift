//
//  ActiveChatsCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SwiftUI

class ActiveChatsCell: UICollectionViewCell, SelfConfiguringCell {
    static var reuseID: String = "ActiveChatCell"
    
    let frendImage = UIImageView()
    let frendName = UILabel(labelText: "user1")
    let lastMessage = UILabel(labelText: "Whats ap!")
    let gradientView = GradientView(from: .topTrailing, to: .bottomLeading, startColor: #colorLiteral(red: 1, green: 0.6655073762, blue: 0.9930477738, alpha: 1), endColor: #colorLiteral(red: 0.5750052333, green: 0.5949758887, blue: 0.9911155105, alpha: 1))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConstraints()
        layer.cornerRadius = 4
        clipsToBounds = true
    }
    
    //MARK: - configure
    func configure(with value: MChat) {
        
        frendImage.image = UIImage(named: value.userImageString)
        frendName.text = value.userName
        lastMessage.text = value.lastMessage
        
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: -  setupConstraints
extension ActiveChatsCell {
    private func setupConstraints() {
        
        frendImage.translatesAutoresizingMaskIntoConstraints = false
        frendName.translatesAutoresizingMaskIntoConstraints = false
        lastMessage.translatesAutoresizingMaskIntoConstraints = false
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        self.backgroundColor = .systemBackground
        gradientView.backgroundColor = .orange
        
        addSubview(frendImage)
        addSubview(frendName)
        addSubview(lastMessage)
        addSubview(gradientView)
        
        NSLayoutConstraint.activate([
            frendImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            frendImage.topAnchor.constraint(equalTo: self.topAnchor),
            frendImage.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            frendImage.widthAnchor.constraint(equalTo: frendImage.heightAnchor),
            
            frendName.leadingAnchor.constraint(equalTo: frendImage.trailingAnchor, constant: 16),
            frendName.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            
            lastMessage.leadingAnchor.constraint(equalTo: frendName.leadingAnchor),
            lastMessage.topAnchor.constraint(equalTo: frendName.bottomAnchor, constant: 16),
            
            gradientView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            gradientView.topAnchor.constraint(equalTo: self.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            gradientView.widthAnchor.constraint(equalToConstant: 8)
        ])
    }
    
}




