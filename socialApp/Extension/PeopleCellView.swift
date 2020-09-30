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
    
    var nameLabel = UILabel(labelText: "", textFont: .avenirBold(size: 16), textColor: .label)
    var distanceLabel = UILabel(labelText: "0.0km", textFont: .avenirRegular(size: 16), textColor: .myGrayColor())
    
    override init(frame: CGRect) {
        super .init(frame: frame)
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PeopleCellView {
    
    private func setup() {

    }
    
    private func setupConstraints(){
     
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(profileImage)
        
        addSubview(profileImage)
        addSubview(nameLabel)
        addSubview(distanceLabel)
  
        
        NSLayoutConstraint.activate([
    
            profileImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            profileImage.trailingAnchor.constraint(equalTo: trailingAnchor),
            profileImage.topAnchor.constraint(equalTo: topAnchor),
            profileImage.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            nameLabel.topAnchor.constraint(equalTo: profileImage.topAnchor, constant: 20),
            
            distanceLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            distanceLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
        ])
        
    }
}
