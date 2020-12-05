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
    let profileName = UILabel(labelText: "",
                              textFont: .avenirBold(size: 24),
                              aligment: .left,
                              linesCount: 0)
    let info = UILabel(labelText: "",
                       textFont: .avenirRegular(size: 16),
                       textColor: .myGrayColor(),
                       aligment: .left,
                       linesCount: 0)
    let infoPremium = UILabel(labelText: "",
                              textFont: .avenirBold(size: 16),
                              textColor: .mySecondSatColor(),
                              aligment: .left,
                              linesCount: 0)
   
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        profileImage.clipsToBounds = true
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.cornerRadius = MDefaultLayer.smallCornerRadius.rawValue
        //animateProfileBack.animationView.play()
    }
    
    func configure(people: MPeople?) {
        guard let people = people else { return }
        if let url = URL(string: people.userImage)  {
            profileImage.sd_setImage(with: url, completed: nil)
        }
        profileName.text = people.displayName
        info.text = [people.dateOfBirth.getStringAge(), people.gender, people.sexuality].joined(separator: ", ").lowercased()
        if people.isGoldMember ||  people.isTestUser{
            infoPremium.text = "Flava premium"
        } else {
            infoPremium.text = ""
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    
    }
    
    private func setupConstraints(){
        addSubview(profileImage)
        addSubview(profileName)
        addSubview(info)
        addSubview(infoPremium)
        
        profileName.translatesAutoresizingMaskIntoConstraints = false
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        info.translatesAutoresizingMaskIntoConstraints = false
        infoPremium.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
           
            
            profileImage.topAnchor.constraint(equalTo: topAnchor),
            profileImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            profileImage.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),
            profileImage.heightAnchor.constraint(equalTo: profileImage.widthAnchor),
            
            profileName.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 5),
            profileName.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileName.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            infoPremium.topAnchor.constraint(equalTo: profileName.bottomAnchor, constant: 0),
            infoPremium.leadingAnchor.constraint(equalTo: profileName.leadingAnchor),
            infoPremium.trailingAnchor.constraint(equalTo: profileName.trailingAnchor),
            
            info.topAnchor.constraint(equalTo: infoPremium.bottomAnchor, constant: 0),
            info.leadingAnchor.constraint(equalTo: profileName.leadingAnchor),
            info.trailingAnchor.constraint(equalTo: profileName.trailingAnchor),
            info.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25)
        ])
    }
}
