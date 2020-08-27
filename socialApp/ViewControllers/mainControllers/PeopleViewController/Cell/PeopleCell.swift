//
//  PeopleCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 26.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit

class PeopleCell: UICollectionViewCell, PeopleConfigurationCell {
    static var reuseID = "PeopleCell"
    
    let photo: UIImageView = {
        let photoImage = UIImageView()
        photoImage.image = #imageLiteral(resourceName: "userPhoto")
        photoImage.clipsToBounds = true
        photoImage.layer.cornerRadius = 4

        photoImage.contentMode = .scaleAspectFit
        photoImage.translatesAutoresizingMaskIntoConstraints = false
        return photoImage
    }()
    
    let distance: UILabel = {
        let label = UILabel()
        label.text = "0.0 km"
        label.textColor = .myHeaderColor()
        label.font = .systemFont(ofSize: 11)
        return label
    }()
    
    let photoBoarder: UIImageView = {
        let photoImage = UIImageView()
        photoImage.image = #imageLiteral(resourceName: "PhotoBorder")
        photoImage.clipsToBounds = true
        photoImage.contentMode = .scaleAspectFit
        photoImage.translatesAutoresizingMaskIntoConstraints = false
        return photoImage
    }()
    
    let likeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "LikeButton"), for: .normal)
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let backView: UIView = {
        let myView = UIView()
        myView.backgroundColor = .systemBackground
        return myView
    }()
    
    let messageBox: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false //for autosize height
        textView.backgroundColor = .systemBackground
        textView.font = .systemFont(ofSize: 18, weight: .regular)
        textView.textColor = .label
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .myBackgroundColor()
        
        setupConstraints()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(with value: MPeople) {
        messageBox.text = value.message
        photo.image = UIImage(named: value.userImageString)
        
        likeButton.isHidden = value.like
    }
    
    private func setupConstraints(){
    
        backView.translatesAutoresizingMaskIntoConstraints = false
        photo.translatesAutoresizingMaskIntoConstraints = false
        messageBox.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        distance.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backView)
        addSubview(photo)
        addSubview(likeButton)
        addSubview(distance)
        addSubview(messageBox)
        
        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: 25),
            
            backView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backView.topAnchor.constraint(equalTo: topAnchor, constant: 25),
            backView.bottomAnchor.constraint(equalTo: messageBox.bottomAnchor, constant: 25),
            
            messageBox.leadingAnchor.constraint(equalTo: photo.trailingAnchor, constant: 5),
            messageBox.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -25),
            messageBox.topAnchor.constraint(equalTo: backView.topAnchor, constant: 25),
    
            
            likeButton.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -25),
            likeButton.topAnchor.constraint(equalTo: backView.bottomAnchor, constant: -25),
            likeButton.widthAnchor.constraint(equalToConstant: 50),
            likeButton.heightAnchor.constraint(equalToConstant: 50),
            
            photo.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 6),
            photo.bottomAnchor.constraint(equalTo: backView.topAnchor, constant: 35),
            photo.widthAnchor.constraint(equalToConstant: 70),
            photo.heightAnchor.constraint(equalToConstant: 70),
            
            distance.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            distance.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -6)
            
        ])
    }
    
}

