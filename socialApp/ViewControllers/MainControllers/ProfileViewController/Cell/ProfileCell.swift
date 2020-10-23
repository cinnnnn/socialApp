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
    let profileName = UILabel(labelText: "",textFont: .avenirBold(size: 24), aligment: .center, linesCount: 0)
    let info = UILabel(labelText: "", textFont: .avenirRegular(size: 16),textColor: .myGrayColor(),aligment: .center, linesCount: 0)
    let animateProfileBack = AnimationCustomView(name: "loading_grayCircle", loopMode: .loop, contentMode: .scaleAspectFit)
   
    
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
        
        animateProfileBack.animationView.play()
    }
    
    func configure(people: MPeople?) {
        guard let people = people else { return }
        if let url = URL(string: people.userImage)  {
            profileImage.sd_setImage(with: url, completed: nil)
        }
        profileName.text = people.displayName
        info.text = [people.dateOfBirth.getStringAge(), people.gender, people.sexuality].joined(separator: ", ").lowercased()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        
    }
    
    private func setupConstraints(){
        
        addSubview(animateProfileBack)
        addSubview(profileImage)
        addSubview(profileName)
        addSubview(info)
        
        profileName.translatesAutoresizingMaskIntoConstraints = false
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        info.translatesAutoresizingMaskIntoConstraints = false
        animateProfileBack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            animateProfileBack.topAnchor.constraint(equalTo: topAnchor),
            animateProfileBack.centerXAnchor.constraint(equalTo: centerXAnchor),
            animateProfileBack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.75),
            animateProfileBack.heightAnchor.constraint(equalTo: animateProfileBack.widthAnchor),
            
            profileImage.centerYAnchor.constraint(equalTo: animateProfileBack.centerYAnchor),
            profileImage.centerXAnchor.constraint(equalTo: animateProfileBack.centerXAnchor),
            profileImage.widthAnchor.constraint(equalTo: animateProfileBack.widthAnchor, multiplier: 0.7),
            profileImage.heightAnchor.constraint(equalTo: profileImage.widthAnchor),
            
            profileName.topAnchor.constraint(equalTo: animateProfileBack.bottomAnchor, constant: 5),
            profileName.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            profileName.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            info.topAnchor.constraint(equalTo: profileName.bottomAnchor, constant: 0),
            info.leadingAnchor.constraint(equalTo: profileName.leadingAnchor),
            info.trailingAnchor.constraint(equalTo: profileName.trailingAnchor),
            info.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -25)
        ])
    }
}
