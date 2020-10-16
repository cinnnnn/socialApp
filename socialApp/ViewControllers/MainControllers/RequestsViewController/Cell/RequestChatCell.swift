//
//  RequestChatCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 17.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SDWebImage

class RequestChatCell: UICollectionViewCell, SelfConfiguringCell {
    static var reuseID: String = "RequestChatCell"
    
    let frendImage = UIImageView(image: nil, contentMode: .scaleAspectFill)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConstraints()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with value: MChat) {
       
        let imageURL = URL(string: value.friendUserImageString )
        frendImage.sd_setImage(with: imageURL, completed: nil)
    }
    
    private func setup() {
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.label.cgColor
        backgroundColor = .systemBackground
        layer.cornerRadius = 4
        clipsToBounds = true
        
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
