//
//  ProfileCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 07.10.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileCell: UICollectionViewCell {
    
    static let reuseID = "ProfileCell"
    
    let profileImage = UIImageView()
    let profileName = UILabel(labelText: "Профиль",textFont: .avenirBold(size: 38), linesCount: 0)
    let profileInfo = UILabel(labelText: "", textFont: .avenirRegular(size: 16),textColor: .myGrayColor(), linesCount: 0)
    let profileSex = UILabel(labelText: "", textFont: .avenirRegular(size: 16),textColor: .myGrayColor(), linesCount: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
       // backgroundColor = .myWhiteColor()
        
        
        profileImage.clipsToBounds = true
        profileImage.contentMode = .scaleAspectFill
        
    }
    
    func configure(people: MPeople?) {
        guard let people = people else { return }
        if let url = URL(string: people.userImage)  {
            profileImage.sd_setImage(with: url, completed: nil)
        }
        profileName.text = people.displayName
        profileInfo.text = people.advert
        profileSex.text = people.sex
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        
    }
    
    private func setupConstraints(){
        
        addSubview(profileImage)
        addSubview(profileName)
        addSubview(profileInfo)
        addSubview(profileSex)
        
        profileName.translatesAutoresizingMaskIntoConstraints = false
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        profileInfo.translatesAutoresizingMaskIntoConstraints = false
        profileSex.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileName.topAnchor.constraint(equalTo: topAnchor, constant: 25),
            profileName.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 25),
            profileName.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 25),
            
            profileImage.topAnchor.constraint(equalTo: topAnchor, constant: 25),
            profileImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            profileImage.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3),
            profileImage.heightAnchor.constraint(equalTo: profileImage.widthAnchor),
            
            profileInfo.topAnchor.constraint(equalTo: profileName.bottomAnchor, constant: 10),
            profileInfo.leadingAnchor.constraint(equalTo: profileName.leadingAnchor),
            profileInfo.trailingAnchor.constraint(equalTo: profileImage.leadingAnchor, constant: -25),
            
            profileSex.topAnchor.constraint(equalTo: profileInfo.bottomAnchor, constant: 0),
            profileSex.leadingAnchor.constraint(equalTo: profileName.leadingAnchor),
            profileSex.trailingAnchor.constraint(equalTo: profileImage.leadingAnchor, constant: -25)
        ])
    }
}
