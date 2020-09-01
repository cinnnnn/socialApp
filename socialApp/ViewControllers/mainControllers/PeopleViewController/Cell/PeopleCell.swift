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
    
    var person: MPeople?
    weak var delegate: PeopleCellDelegate?
    
    let photo: UIImageView = {
        let photoImage = UIImageView()
        photoImage.image = #imageLiteral(resourceName: "userPhoto")
        photoImage.clipsToBounds = true
        photoImage.layer.cornerRadius = 4
       
        photoImage.contentMode = .scaleAspectFill
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
        
        button.backgroundColor = .systemBackground
        
        button.setImage(#imageLiteral(resourceName: "Heart"), for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.label.cgColor
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    let backView: UIView = {
        let myView = UIView()
        myView.backgroundColor = .systemBackground
        myView.layer.borderColor = UIColor.label.cgColor
        myView.layer.borderWidth = 1
        myView.layer.cornerRadius = 4
        return myView
    }()
    
    let messageBox: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false //for autosize height
        textView.backgroundColor = nil
        textView.font = .systemFont(ofSize: 18, weight: .regular)
        textView.textColor = .label
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        setupConstraints()
         
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func pressLike() {
        
        person?.like.toggle()
        
        guard let like = person?.like else { fatalError("Unknown like state")}
        let likeImage = like ? nil : #imageLiteral(resourceName: "Heart")
        likeButton.setImage(likeImage, for: .normal)
        
        guard let newPerson = person else { fatalError("person unknown")}
        delegate?.likeTupped(user: newPerson)
        print("Like in cell")
        
    }
        //MARK: - setup()
    private func setup() {
        likeButton.addTarget(self, action: #selector(pressLike), for: .touchUpInside)
        
        backgroundColor = .systemBackground
    }
    
    //MARK: - configure()
    func configure(with value: MPeople) {
        person = value
        
        messageBox.text = value.message
        photo.image = UIImage(named: value.userImageString)
        
        let likeImage = value.like ? nil : #imageLiteral(resourceName: "Heart")
        likeButton.setImage(likeImage, for: .normal)
        
    }
    
    private func setupConstraints(){
    
        backView.translatesAutoresizingMaskIntoConstraints = false
        photo.translatesAutoresizingMaskIntoConstraints = false
        messageBox.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        distance.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backView)
        addSubview(photo)
        addSubview(distance)
        addSubview(messageBox)
        addSubview(likeButton)
        
        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: backView.bottomAnchor),
            
            backView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            backView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            backView.topAnchor.constraint(equalTo: topAnchor, constant: 25),
            backView.bottomAnchor.constraint(equalTo: messageBox.bottomAnchor, constant: 35),
            
            messageBox.leadingAnchor.constraint(equalTo: photo.trailingAnchor, constant: 5),
            messageBox.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -55),
            messageBox.topAnchor.constraint(equalTo: backView.topAnchor, constant: 6),
    
            
            likeButton.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -6),
            likeButton.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -6),
            likeButton.widthAnchor.constraint(equalToConstant: 50),
            likeButton.heightAnchor.constraint(equalToConstant: 50),
            
            photo.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 6),
            photo.topAnchor.constraint(equalTo: backView.topAnchor,constant: 6),
            photo.widthAnchor.constraint(equalToConstant: 50),
            photo.heightAnchor.constraint(equalToConstant: 50),
            
            distance.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 6),
            distance.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -6)
            
        ])
        
    }
    
}

