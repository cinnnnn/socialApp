//
//  PeopleCell.swift
//  socialApp
//
//  Created by Денис Щиголев on 26.08.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import SDWebImage

class PeopleCell: UICollectionViewCell, PeopleConfigurationCell {
    
    
    static var reuseID = "PeopleCell"
    
    var person: MPeople?
    weak var delegate: PeopleCellDelegate?
    
    let profileImage = ProfileImageView()
    let distance = UILabel(labelText: "0.0km", textFont: .systemFont(ofSize: 11, weight: .light))
    let topLine: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.backgroundColor = .label
        return view
    }()
    let bottomLine: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.backgroundColor = .label
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let likeButton: UIButton = {
        let button = UIButton()
        
        button.clipsToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.label.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("L", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .heavy)
        button.backgroundColor = .systemBackground
        return button
    }()
    
    let backView: UIView = {
        let myView = UIView()
        myView.backgroundColor = .systemBackground
        myView.layer.borderColor = UIColor.label.cgColor
        myView.layer.borderWidth = 0
        myView.layer.cornerRadius = 0
        return myView
    }()
    
    let messageBox: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.isScrollEnabled = false //for autosize height
        textView.backgroundColor = nil
        textView.font = .systemFont(ofSize: 18, weight: .bold)
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
        
//        person?.like.toggle()
//
//        guard let like = person?.like else { fatalError("Unknown like state")}
//        let likeImage = like ? nil : #imageLiteral(resourceName: "Heart")
//        likeButton.setImage(likeImage, for: .normal)
//
//        guard let newPerson = person else { fatalError("person unknown")}
//        delegate?.likeTupped(user: newPerson)
//        print("Like in cell")
        
    }
        //MARK: - setup()
    private func setup() {
        likeButton.addTarget(self, action: #selector(pressLike), for: .touchUpInside)
        
        backgroundColor = .systemBackground
        backView.isUserInteractionEnabled = true
        
        backView.translatesAutoresizingMaskIntoConstraints = false
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        messageBox.translatesAutoresizingMaskIntoConstraints = false
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        distance.translatesAutoresizingMaskIntoConstraints = false
        topLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backView)
        addSubview(topLine)
        addSubview(bottomLine)
        addSubview(distance)
        addSubview(messageBox)
        addSubview(likeButton)
        addSubview(profileImage)
        
    }
    
    //MARK: - configure()
    func configure(with value: MPeople) {
        person = value
        
        messageBox.text = value.advert
        
        let imageURL = URL(string: value.userImage)
        profileImage.profileImage.sd_setImage(with: imageURL, completed: nil)
        
        //        let likeImage = value.like ? nil : #imageLiteral(resourceName: "Heart")
        //        likeButton.setImage(likeImage, for: .normal)
        
    }
    
    override func prepareForReuse() {
        profileImage.profileImage.image = nil
    }
    private func setupConstraints(){
        
        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: backView.bottomAnchor),
            
            profileImage.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 25),
            profileImage.topAnchor.constraint(equalTo: topAnchor),
            profileImage.widthAnchor.constraint(equalToConstant: 50),
            profileImage.heightAnchor.constraint(equalToConstant: 50),
            
            messageBox.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor, constant: -6),
            messageBox.trailingAnchor.constraint(equalTo: likeButton.trailingAnchor),
            messageBox.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 6),
           
            likeButton.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -25),
            likeButton.topAnchor.constraint(equalTo: messageBox.bottomAnchor, constant: 6),
            likeButton.widthAnchor.constraint(equalToConstant: 50),
            likeButton.heightAnchor.constraint(equalToConstant: 50),
            
            backView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            backView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            backView.topAnchor.constraint(equalTo: profileImage.centerYAnchor),
            backView.bottomAnchor.constraint(equalTo: likeButton.centerYAnchor),
            
            topLine.leadingAnchor.constraint(equalTo: backView.leadingAnchor),
            topLine.trailingAnchor.constraint(equalTo: backView.trailingAnchor),
            topLine.topAnchor.constraint(equalTo: backView.topAnchor),
            topLine.heightAnchor.constraint(equalToConstant: 1),
            
            bottomLine.leadingAnchor.constraint(equalTo: backView.leadingAnchor),
            bottomLine.trailingAnchor.constraint(equalTo: backView.trailingAnchor),
            bottomLine.bottomAnchor.constraint(equalTo: backView.bottomAnchor),
            bottomLine.heightAnchor.constraint(equalToConstant: 1),
            
            distance.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            distance.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -6)
            
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        likeButton.layer.cornerRadius = likeButton.frame.height / 2
        setupConstraints()
    }
    
}

