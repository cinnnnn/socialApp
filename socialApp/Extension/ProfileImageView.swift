//
//  ProfileImageView.swift
//  socialApp
//
//  Created by Денис Щиголев on 04.07.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class ProfileImageView: UIView {

    let backgroundView: UIView = {
        let myView = UIView()
        myView.backgroundColor = .label
        myView.translatesAutoresizingMaskIntoConstraints = false
        return myView
    }()
    
    let profileImage: UIImageView = {
        let myImage = UIImageView()
        myImage.sd_imageTransition = .flipFromBottom
        myImage.image = #imageLiteral(resourceName: "avatar")
        myImage.clipsToBounds = true
        myImage.contentMode = .scaleAspectFill
        myImage.translatesAutoresizingMaskIntoConstraints = false
        
        return myImage
    }()
    
    let plusButton: UIButton = {
        let myButton = UIButton()
        
        myButton.setImage(#imageLiteral(resourceName: "PlusButton"), for: .normal)
        myButton.translatesAutoresizingMaskIntoConstraints = false
        
        return myButton
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(backgroundView)
        addSubview(profileImage)
        addSubview(plusButton)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            
            profileImage.topAnchor.constraint(equalTo: self.topAnchor),
            profileImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            profileImage.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.75),
            profileImage.widthAnchor.constraint(equalTo: profileImage.heightAnchor, multiplier: 1),
            
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.75),
            backgroundView.widthAnchor.constraint(equalTo: backgroundView.heightAnchor, multiplier: 1),
            
            plusButton.topAnchor.constraint(equalTo: profileImage.bottomAnchor),
            plusButton.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor),
            plusButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.25),
            plusButton.widthAnchor.constraint(equalTo: plusButton.heightAnchor, multiplier: 1),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
    
    }

}
