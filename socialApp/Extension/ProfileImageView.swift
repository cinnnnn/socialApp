//
//  ProfileImageView.swift
//  socialApp
//
//  Created by Денис Щиголев on 18.09.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class ProfileImageView: UIView {
    
    let profileImage: UIImageView = {
        let myImage = UIImageView()
        myImage.sd_imageTransition = .flipFromBottom
        myImage.image = #imageLiteral(resourceName: "avatar")
        myImage.clipsToBounds = true
        myImage.contentMode = .scaleAspectFill
        myImage.translatesAutoresizingMaskIntoConstraints = false
        
        return myImage
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        addSubview(profileImage)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            profileImage.topAnchor.constraint(equalTo: self.topAnchor),
            profileImage.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            profileImage.heightAnchor.constraint(equalTo: self.heightAnchor),
            profileImage.widthAnchor.constraint(equalTo: profileImage.heightAnchor, multiplier: 1),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
    }
}
