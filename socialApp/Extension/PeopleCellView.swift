//
//  PeopleCellView.swift
//  socialApp
//
//  Created by Денис Щиголев on 30.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class PeopleCellView: UIView {
    
    let profileImage: UIImageView = {
        let myImage = UIImageView()
        myImage.sd_imageTransition = .flipFromBottom
        myImage.image = #imageLiteral(resourceName: "avatar")
        myImage.clipsToBounds = true
        myImage.contentMode = .scaleAspectFill
        myImage.translatesAutoresizingMaskIntoConstraints = false
        myImage.layer.cornerRadius = 4
        
        return myImage
    }()
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PeopleCellView {
    
    private func setupConstraints(){
     
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(profileImage)
  
        NSLayoutConstraint.activate([
            profileImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            profileImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            profileImage.topAnchor.constraint(equalTo: topAnchor),
            profileImage.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
    }
}
