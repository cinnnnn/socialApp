//
//  WaitingChatsCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 13.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SDWebImage

class NewChatsCell: UICollectionViewCell,SelfConfiguringCell {
    static var reuseID: String = "NewChatsCell"
    
    let frendImage = UIImageView(image: nil, contentMode: .scaleAspectFill)
    
    func configure(with value: MChat, currentUser: MPeople) {
       
        let imageURL = URL(string: value.friendUserImageString )
        frendImage.sd_setImage(with: imageURL, completed: nil)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConstraints()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        backgroundColor = .myWhiteColor()
        clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = self.frame.width / 2
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
