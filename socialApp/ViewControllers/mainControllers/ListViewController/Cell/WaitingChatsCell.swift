//
//  WaitingChatsCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class WaitingChatsCell: UICollectionViewCell,SelfConfiguringCell {
    static var reuseID: String = "WaitingChatsCell"
    
    let frendImage = UIImageView(image: nil, contentMode: .scaleAspectFill)
    
    func configure(with value: MChat) {
        frendImage.image = UIImage(named: value.userImageString)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConstraints()
        
        backgroundColor = .systemBackground
        layer.cornerRadius = 4
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints(){
        
        frendImage.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(frendImage)
        
        NSLayoutConstraint.activate([
            frendImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            frendImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            frendImage.topAnchor.constraint(equalTo: topAnchor),
            frendImage.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
